class Domain < ActiveRecord::Base
  #TODO whois requests ip whitelist for full info for own domains and partial info for other domains
  #TODO most inputs should be trimmed before validatation, probably some global logic?

  include EppErrors

  EPP_CODE_MAP = {
    '2302' => ['Domain name already exists', 'Domain name is reserved or restricted'], # Object exists
    '2306' => ['Registrant is missing', 'Admin contact is missing', 'Given and current expire dates do not match'], # Parameter policy error
    '2004' => ['Nameservers count must be between 1-13', 'Period must add up to 1, 2 or 3 years'], # Parameter value range error
    '2303' => ['Registrant not found', 'Contact was not found'] # Object does not exist
  }

  EPP_ATTR_MAP = {
    owner_contact: 'registrant',
    name_dirty: 'name',
    period: 'period'
  }

  belongs_to :registrar
  belongs_to :owner_contact, class_name: 'Contact'

  has_many :domain_contacts

  has_many :tech_contacts, -> {
    where(domain_contacts: {contact_type: Contact::CONTACT_TYPE_TECH})
  }, through: :domain_contacts, source: :contact

  has_many :admin_contacts, -> {
    where(domain_contacts: {contact_type: Contact::CONTACT_TYPE_ADMIN})
  }, through: :domain_contacts, source: :contact

  has_and_belongs_to_many :nameservers

  validates :name_dirty, domain_name: true, uniqueness: true
  validates :period, numericality: { only_integer: true }
  validates :name, :owner_contact, presence: true

  validates_associated :nameservers

  validate :validate_period
  validate :validate_nameservers_count
  validate :validate_admin_contacts_count

  def name=(value)
    value.strip!
    write_attribute(:name, SimpleIDN.to_unicode(value))
    write_attribute(:name_puny, SimpleIDN.to_ascii(value))
    write_attribute(:name_dirty, value)
  end

  ### CREATE ###

  def attach_objects(ph, parsed_frame)
    attach_owner_contact(ph[:registrant])
    attach_contacts(self.class.parse_contacts_from_frame(parsed_frame))
    attach_nameservers(self.class.parse_nameservers_from_params(ph[:ns]))

    errors.empty?
  end

  def attach_owner_contact(code)
    self.owner_contact = Contact.find_by(code: code)

    errors.add(:owner_contact, {
      obj: 'registrant',
      val: code,
      msg: I18n.t('errors.messages.epp_registrant_not_found')
    }) unless owner_contact
  end

  def attach_contacts(contacts)
    contacts.each do |k, v|
      v.each do |x|
        if contact = Contact.find_by(code: x[:contact])
          attach_contact(k, contact)
        else
          # Detailed error message with value to display in EPP response
          errors.add(:domain_contacts, {
            obj: 'contact',
            val: x[:contact],
            msg: errors.generate_message(:domain_contacts, :not_found)
          })
        end
      end
    end

    if owner_contact
      attach_contact(Contact::CONTACT_TYPE_TECH, owner_contact) if tech_contacts.empty?

      if owner_contact.citizen?
        attach_contact(Contact::CONTACT_TYPE_ADMIN, owner_contact) if admin_contacts.empty?
      end
    end
  end

  def attach_contact(type, contact)
    tech_contacts << contact if type.to_sym == :tech
    admin_contacts << contact if type.to_sym == :admin
  end

  def attach_nameservers(ns_list)
    ns_list.each do |ns|
      attach_nameserver(ns)
    end
  end

  def attach_nameserver(ns)
    self.nameservers.build(hostname: ns) and return if ns.is_a?(String)

    attrs = {hostname: ns[:hostName]}

    if ns[:hostAddr]
      if ns[:hostAddr].is_a?(Array)
        ns[:hostAddr].each do |ip|
          attrs[:ip] = ip unless attrs[:ip]
        end
      else
        attrs[:ip] = ns[:hostAddr]
      end
    end

    self.nameservers.build(attrs)
  end

  ### RENEW ###

  def renew(cur_exp_date, period, unit='y')
    # TODO Check how much time before domain exp date can it be renewed
    validate_exp_dates(cur_exp_date)
    return false if errors.any?

    p = self.class.convert_period_to_time(period, unit)

    self.valid_to = self.valid_to + p
    self.period = period
    self.period_unit = unit
    save
  end

  ### VALIDATIONS ###

  def validate_nameservers_count
    unless nameservers.length.between?(1, 13)
      errors.add(:nameservers, :out_of_range, {min: 1, max: 13})
    end
  end

  def validate_admin_contacts_count
    errors.add(:admin_contacts, :blank) if admin_contacts.empty?
  end

  def validate_period
    return unless period.present?
    if period_unit == 'd'
      valid_values = ['365', '366', '710', '712', '1065', '1068']
    elsif period_unit == 'm'
      valid_values = ['12', '24', '36']
    else
      valid_values = ['1', '2', '3']
    end

    errors.add(:period, :out_of_range) unless valid_values.include?(period.to_s)
  end

  def validate_exp_dates(cur_exp_date)
    errors.add(:valid_to, {
      obj: 'curExpDate',
      val: cur_exp_date,
      msg: I18n.t('errors.messages.epp_exp_dates_do_not_match')
    }) if cur_exp_date.to_date != valid_to
  end

  class << self
    def convert_period_to_time(period, unit)
      p = period.to_i.days  if unit == 'd'
      p = period.to_i.months if unit == 'm'
      p = period.to_i.years if unit == 'y'
      p
    end

    def parse_contacts_from_frame(parsed_frame)
      res = {}
      Contact::CONTACT_TYPES.each do |ct|
        res[ct.to_sym] ||= []
        parsed_frame.css("contact[type='#{ct}']").each do |x|
          res[ct.to_sym] << Hash.from_xml(x.to_s).with_indifferent_access
        end
      end

      res
    end

    def parse_nameservers_from_params(ph)
      return [] unless ph
      return ph[:hostObj] if ph[:hostObj]
      return ph[:hostAttr] if ph[:hostAttr]
      []
    end

    def parse_period_unit_from_frame(parsed_frame)
      p = parsed_frame.css('period').first
      return nil unless p
      p[:unit]
    end

    def check_availability(domains)
      domains = [domains] if domains.is_a?(String)

      res = []
      domains.each do |x|
        if !DomainNameValidator.validate_format(x)
          res << {name: x, avail: 0, reason: 'invalid format'}
          next
        end

        if !DomainNameValidator.validate_reservation(x)
          res << {name: x, avail: 0, reason: I18n.t('errors.messages.epp_domain_reserved')}
          next
        end

        if Domain.find_by(name: x)
          res << {name: x, avail: 0, reason: 'in use'} #confirm reason with current API
        else
          res << {name: x, avail: 1}
        end
      end

      res
    end
  end
end
