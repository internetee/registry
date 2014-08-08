class Domain < ActiveRecord::Base
  #TODO whois requests ip whitelist for full info for own domains and partial info for other domains
  #TODO most inputs should be trimmed before validatation, probably some global logic?

  include EppErrors

  EPP_CODE_MAP = {
    '2302' => ['Domain name already exists', 'Domain name is reserved or restricted'], # Object exists
    '2306' => ['Registrant is missing', 'Admin contact is missing', 'Given and current expire dates do not match'], # Parameter policy error
    '2004' => ['Nameservers count must be between 1-13'], # Parameter value range error
    '2303' => ['Contact was not found'] # Object does not exist
  }

  EPP_ATTR_MAP = {
    owner_contact: 'registrant'
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
  validates :period, numericality: { only_integer: true, greater_than: 0, less_than: 100 }
  validates :name, :owner_contact, presence: true
  validates_associated :nameservers

  def name=(value)
    value.strip!
    write_attribute(:name, SimpleIDN.to_unicode(value))
    write_attribute(:name_puny, SimpleIDN.to_ascii(value))
    write_attribute(:name_dirty, value)
  end

  def attach_contacts(contacts)
    contacts.each do |k, v|
      v.each do |x|
        contact = Contact.find_by(code: x[:contact])
        attach_contact(k, contact) and next if contact

        # Detailed error message with value to display in EPP response
        errors.add(:domain_contacts, {
          obj: 'contact',
          val: x[:contact],
          msg: errors.generate_message(:domain_contacts, :not_found)
        })
      end
    end

    attach_contact(Contact::CONTACT_TYPE_TECH, owner_contact) if tech_contacts.empty?

    if owner_contact.citizen?
      attach_contact(Contact::CONTACT_TYPE_ADMIN, owner_contact) if admin_contacts.empty?
    end

    validate_admin_contacts_count

    errors.empty?
  end

  def attach_contact(type, contact)
    domain_contacts.create(
      contact: contact,
      contact_type: type
    )
  end

  def attach_nameservers(ns_list)
    ns_list.each do |ns|
      attach_nameserver(ns)
    end

    save

    validate_nameservers_count

    errors.empty?
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

  def validate_nameservers_count
    unless nameservers.count.between?(1, 13)
      errors.add(:nameservers, :out_of_range, {min: 1, max: 13})
    end

    errors.empty?
  end

  def validate_admin_contacts_count
    errors.add(:admin_contacts, :blank) if admin_contacts.empty?
  end

  def renew(cur_exp_date, period, unit='y')
    if cur_exp_date.to_date == valid_to
      self.valid_to = self.valid_to + period.to_i.years
      self.period = period
      save
    else
      errors[:base] << {msg: I18n.t('errors.messages.epp_exp_dates_do_not_match'), obj: 'curExpDate', val: cur_exp_date}
      false
    end
  end

  class << self
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
