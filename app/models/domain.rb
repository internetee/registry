class Domain < ActiveRecord::Base
  #TODO whois requests ip whitelist for full info for own domains and partial info for other domains
  #TODO most inputs should be trimmed before validatation, probably some global logic?

  include EppErrors

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

  delegate :code, to: :owner_contact, prefix: true
  delegate :name, to: :registrar, prefix: true

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
    attach_nameservers(self.class.parse_nameservers_from_frame(parsed_frame))

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
    ns_list.each do |ns_attrs|
      self.nameservers.build(ns_attrs)
    end
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
    sg = SettingGroup.domain_validation
    min, max = sg.setting(:ns_min_count).value.to_i, sg.setting(:ns_max_count).value.to_i

    unless nameservers.length.between?(min, max)
      errors.add(:nameservers, :out_of_range, {min: min, max: max})
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

  def epp_code_map
    domain_validation_sg = SettingGroup.domain_validation

    {
      '2302' => [ # Object exists
        [:name_dirty, :taken],
        [:name_dirty, :reserved]
      ],
      '2306' => [ # Parameter policy error
        [:owner_contact, :blank],
        [:admin_contacts, :blank],
        [:valid_to, :epp_exp_dates_do_not_match]
      ],
      '2004' => [ # Parameter value range error
        [:nameservers, :out_of_range, {min: domain_validation_sg.setting(:ns_min_count).value, max: domain_validation_sg.setting(:ns_max_count).value}],
        [:period, :out_of_range]
      ],
      '2303' => [ # Object does not exist
        [:owner_contact, :epp_registrant_not_found],
        [:domain_contacts, :not_found]
      ],
      '2200' => [
        [:auth_info, :wrong_pw]
      ]
    }
  end

  ## SHARED

  # For domain transfer
  def authenticate(pw)
    errors.add(:auth_info, {msg: errors.generate_message(:auth_info, :wrong_pw)}) if pw != auth_info
    errors.empty?
  end

  class << self
    def convert_period_to_time(period, unit)
      return period.to_i.days if unit == 'd'
      return period.to_i.months if unit == 'm'
      return period.to_i.years if unit == 'y'
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

    def parse_nameservers_from_frame(parsed_frame)
      res = []
      parsed_frame.css('hostAttr').each do |x|
        res << {
          hostname: x.css('hostName').first.try(:text),
          ipv4: x.css('hostAddr[ip="v4"]').first.try(:text),
          ipv6: x.css('hostAddr[ip="v6"]').first.try(:text)
        }
      end

      parsed_frame.css('hostObj').each do |x|
        res << {
          hostname: x.text
        }
      end

      res
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
