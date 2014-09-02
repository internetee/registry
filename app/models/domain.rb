class Domain < ActiveRecord::Base
  # TODO whois requests ip whitelist for full info for own domains and partial info for other domains
  # TODO most inputs should be trimmed before validatation, probably some global logic?

  include EppErrors

  EPP_ATTR_MAP = {
    owner_contact: 'registrant',
    name_dirty: 'name',
    period: 'period'
  }

  belongs_to :registrar
  belongs_to :owner_contact, class_name: 'Contact'

  has_many :domain_contacts, dependent: :delete_all

  has_many :tech_contacts, -> do
    where(domain_contacts: { contact_type: DomainContact::TECH })
  end, through: :domain_contacts, source: :contact

  has_many :admin_contacts, -> do
    where(domain_contacts: { contact_type: DomainContact::ADMIN })
  end, through: :domain_contacts, source: :contact

  has_many :domain_nameservers, dependent: :delete_all
  has_many :nameservers, through: :domain_nameservers

  has_many :domain_statuses, dependent: :delete_all

  has_many :domain_transfers, dependent: :delete_all

  delegate :code, to: :owner_contact, prefix: true
  delegate :name, to: :registrar, prefix: true

  validates :name_dirty, domain_name: true, uniqueness: true
  validates :period, numericality: { only_integer: true }
  validates :name, :owner_contact, presence: true

  validate :validate_period
  validate :validate_nameservers_count
  validate :validate_admin_contacts_count

  def name=(value)
    value.strip!
    write_attribute(:name, SimpleIDN.to_unicode(value))
    write_attribute(:name_puny, SimpleIDN.to_ascii(value))
    write_attribute(:name_dirty, value)
  end

  ### CREATE & UPDATE ###

  def parse_and_attach_domain_dependencies(ph, parsed_frame)
    attach_owner_contact(ph[:registrant]) if ph[:registrant]
    attach_contacts(self.class.parse_contacts_from_frame(parsed_frame))
    attach_nameservers(self.class.parse_nameservers_from_frame(parsed_frame))
    attach_statuses(self.class.parse_statuses_from_frame(parsed_frame))

    errors.empty?
  end

  def parse_and_detach_domain_dependencies(parsed_frame)
    detach_contacts(self.class.parse_contacts_from_frame(parsed_frame))
    detach_nameservers(self.class.parse_nameservers_from_frame(parsed_frame))
    detach_statuses(self.class.parse_statuses_from_frame(parsed_frame))

    errors.empty?
  end

  def parse_and_update_domain_dependencies(parsed_frame)
    owner_contact_code = parsed_frame.css('registrant').try(:text)
    attach_owner_contact(owner_contact_code) if owner_contact_code.present?

    errors.empty?
  end

  def parse_and_update_domain_attributes(parsed_frame)
    assign_attributes(self.class.parse_update_params_from_frame(parsed_frame))

    errors.empty?
  end

  def attach_owner_contact(code)
    self.owner_contact = Contact.find_by(code: code)

    return if owner_contact

    add_epp_error('2303', 'registrant', code, [:owner_contact, :not_found])
  end

  def attach_contacts(contacts)
    contacts.each do |k, v|
      v.each do |x|
        contact = Contact.find_by(code: x[:contact])
        if contact
          attach_contact(k, contact)
        else
          # Detailed error message with value to display in EPP response
          add_epp_error('2303', 'contact', x[:contact], [:domain_contacts, :not_found])
        end
      end
    end

    return unless owner_contact

    attach_contact(DomainContact::TECH, owner_contact) if tech_contacts_count.zero?
    attach_contact(DomainContact::ADMIN, owner_contact) if admin_contacts_count.zero? && owner_contact.citizen?
  end

  def attach_contact(type, contact)
    domain_contacts.build(contact: contact, contact_type: DomainContact::TECH) if type.to_sym == :tech
    domain_contacts.build(contact: contact, contact_type: DomainContact::ADMIN) if type.to_sym == :admin
  end

  def attach_nameservers(ns_list)
    ns_list.each do |ns_attrs|
      existing = nameservers.select { |x| x.hostname == ns_attrs[:hostname] }

      nameservers.build(ns_attrs)

      next if existing.empty?
      add_epp_error('2302', 'hostObj', ns_attrs[:hostname], [:nameservers, :taken])
    end
  end

  def attach_statuses(status_list)
    status_list.each do |x|
      existing = domain_statuses.select { |o| o.value == x[:value] }

      if existing.any?
        add_epp_error('2302', 'status', x[:value], [:domain_statuses, :taken])
        next
      end

      unless DomainStatus::STATUSES.include?(x[:value])
        add_epp_error('2302', 'status', x[:value], [:domain_statuses, :not_found])
        next
      end

      domain_statuses.build(
        value: x[:value],
        description: x[:description]
      )
    end
  end

  def detach_contacts(contact_list)
    to_delete = []
    contact_list.each do |k, v|
      v.each do |x|
        contact = domain_contacts.joins(:contact).where(contacts: { code: x[:contact] }, contact_type: k.to_s)
        if contact.blank?
          add_epp_error('2303', 'contact', x[:contact], [:domain_contacts, :not_found])
        else
          to_delete << contact
        end
      end
    end

    domain_contacts.delete(to_delete)
  end

  def detach_nameservers(ns_list)
    to_delete = []
    ns_list.each do |ns_attrs|
      nameserver = nameservers.where(ns_attrs)
      if nameserver.blank?
        add_epp_error('2303', 'hostObj', ns_attrs[:hostname], [:nameservers, :not_found])
      else
        to_delete << nameserver
      end
    end

    nameservers.delete(to_delete)
  end

  def detach_statuses(status_list)
    to_delete = []
    status_list.each do |x|
      status = domain_statuses.find_by(value: x[:value])
      if status.blank?
        add_epp_error('2303', 'status', x[:value], [:domain_statuses, :not_found])
      else
        to_delete << status
      end
    end

    domain_statuses.delete(to_delete)
  end

  ### RENEW ###

  def renew(cur_exp_date, period, unit = 'y')
    # TODO: Check how much time before domain exp date can it be renewed
    validate_exp_dates(cur_exp_date)
    return false if errors.any?

    p = self.class.convert_period_to_time(period, unit)

    self.valid_to = valid_to + p
    self.period = period
    self.period_unit = unit
    save
  end

  ### TRANSFER ###

  def transfer(params)
    return false unless authenticate(params[:pw])

    if pending_transfer && params[:action] == 'approve'
      approve_pending_transfer and return true
    end

    return true if pending_transfer

    wait_time = SettingGroup.domain_general.setting(:transfer_wait_time).value.to_i

    if wait_time > 0
      domain_transfers.create(
        status: DomainTransfer::PENDING,
        transfer_requested_at: Time.zone.now,
        transfer_to: params[:current_user].registrar,
        transfer_from: registrar
      )
    else
      domain_transfers.create(
        status: DomainTransfer::SERVER_APPROVED,
        transfer_requested_at: Time.zone.now,
        transferred_at: Time.zone.now,
        transfer_to: params[:current_user].registrar,
        transfer_from: registrar
      )

      self.registrar = params[:current_user].registrar
      save
    end
  end

  def approve_pending_transfer
    p = pending_transfer
    p.update(
      status: DomainTransfer::CLIENT_APPROVED,
      transferred_at: Time.zone.now
    )

    self.registrar = p.transfer_to
    save
  end

  def pending_transfer
    domain_transfers.find_by(status: DomainTransfer::PENDING)
  end

  ### VALIDATIONS ###

  def validate_nameservers_count
    sg = SettingGroup.domain_validation
    min, max = sg.setting(:ns_min_count).value.to_i, sg.setting(:ns_max_count).value.to_i

    return if nameservers.length.between?(min, max)
    errors.add(:nameservers, :out_of_range, { min: min, max: max })
  end

  def validate_admin_contacts_count
    errors.add(:admin_contacts, :out_of_range) if admin_contacts_count.zero?
  end

  def validate_period
    return unless period.present?
    if period_unit == 'd'
      valid_values = %w(365 366 710 712 1065 1068)
    elsif period_unit == 'm'
      valid_values = %w(12 24 36)
    else
      valid_values = %w(1 2 3)
    end

    errors.add(:period, :out_of_range) unless valid_values.include?(period.to_s)
  end

  def validate_exp_dates(cur_exp_date)
    return if cur_exp_date.to_date == valid_to
    add_epp_error('2306', 'curExpDate', cur_exp_date, I18n.t('errors.messages.epp_exp_dates_do_not_match'))
  end

  def epp_code_map # rubocop:disable Metrics/MethodLength
    domain_validation_sg = SettingGroup.domain_validation

    {
      '2302' => [ # Object exists
        [:name_dirty, :taken],
        [:name_dirty, :reserved]
      ],
      '2306' => [ # Parameter policy error
        [:owner_contact, :blank],
        [:admin_contacts, :out_of_range]
      ],
      '2004' => [ # Parameter value range error
        [:nameservers, :out_of_range,
          {
            min: domain_validation_sg.setting(:ns_min_count).value,
            max: domain_validation_sg.setting(:ns_max_count).value
          }
        ],
        [:period, :out_of_range]
      ],
      '2200' => [
        [:auth_info, :wrong_pw]
      ]
    }
  end

  ## SHARED

  # For domain transfer
  def authenticate(pw)
    errors.add(:auth_info, { msg: errors.generate_message(:auth_info, :wrong_pw) }) if pw != auth_info
    errors.empty?
  end

  def tech_contacts_count
    domain_contacts.select { |x| x.contact_type == DomainContact::TECH }.count
  end

  def admin_contacts_count
    domain_contacts.select { |x| x.contact_type == DomainContact::ADMIN }.count
  end

  class << self
    def convert_period_to_time(period, unit)
      return period.to_i.days if unit == 'd'
      return period.to_i.months if unit == 'm'
      return period.to_i.years if unit == 'y'
    end

    def parse_contacts_from_frame(parsed_frame)
      res = {}
      DomainContact::TYPES.each do |ct|
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

    def parse_statuses_from_frame(parsed_frame)
      res = []

      parsed_frame.css('status').each do |x|
        res << {
          value: x['s'],
          description: x.text
        }
      end
      res
    end

    def parse_update_params_from_frame(parsed_frame)
      ret = {}
      return ret if parsed_frame.blank?

      ret[:auth_info] = parsed_frame.css('pw').try(:text)

      ret.compact
    end

    def check_availability(domains)
      domains = [domains] if domains.is_a?(String)

      res = []
      domains.each do |x|
        unless DomainNameValidator.validate_format(x)
          res << { name: x, avail: 0, reason: 'invalid format' }
          next
        end

        unless DomainNameValidator.validate_reservation(x)
          res << { name: x, avail: 0, reason: I18n.t('errors.messages.epp_domain_reserved') }
          next
        end

        if Domain.find_by(name: x)
          res << { name: x, avail: 0, reason: 'in use' }
        else
          res << { name: x, avail: 1 }
        end
      end

      res
    end
  end
end
