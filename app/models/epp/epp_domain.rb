# rubocop: disable Metrics/ClassLength
class Epp::EppDomain < Domain
  include EppErrors

  validate :validate_nameservers_count
  validate :validate_admin_contacts_count

  def epp_code_map # rubocop:disable Metrics/MethodLength
    {
      '2002' => [
        [:base, :domain_already_belongs_to_the_querying_registrar]
      ],
      '2302' => [ # Object exists
        [:name_dirty, :taken, { value: { obj: 'name', val: name_dirty } }],
        [:name_dirty, :reserved, { value: { obj: 'name', val: name_dirty } }]
      ],
      '2304' => [
        [:base, :domain_status_prohibits_operation]
      ],
      '2306' => [ # Parameter policy error
        [:owner_contact, :blank],
        [:admin_contacts, :out_of_range],
        [:base, :ds_data_with_key_not_allowed],
        [:base, :ds_data_not_allowed],
        [:base, :key_data_not_allowed]
      ],
      '2004' => [ # Parameter value range error
        [:nameservers, :out_of_range,
         {
           min: Setting.ns_min_count,
           max: Setting.ns_max_count
         }
        ],
        [:period, :out_of_range, { value: { obj: 'period', val: period } }],
        [:dnskeys, :out_of_range,
         {
           min: Setting.dnskeys_min_count,
           max: Setting.dnskeys_max_count
         }
        ]
      ],
      '2200' => [
        [:auth_info, :wrong_pw]
      ]
    }
  end

  def parse_and_attach_domain_dependencies(parsed_frame)
    attach_owner_contact(self.class.parse_owner_contact_from_frame(parsed_frame))
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

  def parse_and_attach_ds_data(parsed_frame)
    attach_dnskeys(self.class.parse_dnskeys_from_frame(parsed_frame))

    errors.empty?
  end

  def parse_and_detach_ds_data(parsed_frame)
    detach_dnskeys(self.class.parse_dnskeys_from_frame(parsed_frame))

    errors.empty?
  end

  def parse_and_update_domain_dependencies(parsed_frame)
    owner_contact_code = parsed_frame.css('registrant').try(:text)
    attach_owner_contact(owner_contact_code) if owner_contact_code.present?

    errors.empty?
  end

  # TODO: Find out if there are any attributes that can be changed
  # if not, delete this method
  def parse_and_update_domain_attributes(_parsed_frame)
    # assign_attributes(self.class.parse_update_params_from_frame(parsed_frame))

    errors.empty?
  end

  def attach_owner_contact(code)
    return unless code
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
      nameservers.build(ns_attrs)
    end
  end

  def attach_statuses(status_list)
    status_list.each do |x|
      unless DomainStatus::STATUSES.include?(x[:value])
        add_epp_error('2303', 'status', x[:value], [:domain_statuses, :not_found])
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

  def attach_dnskeys(dnssec_data)
    return false unless validate_dnssec_data(dnssec_data)

    dnssec_data[:ds_data].each do |ds_data|
      dnskeys.build(ds_data)
    end

    dnssec_data[:key_data].each do |x|
      dnskeys.build({
        ds_key_tag: SecureRandom.hex(5),
        ds_alg: 3,
        ds_digest_type: Setting.ds_algorithm
      }.merge(x))
    end
  end

  def validate_dnssec_data(dnssec_data)
    ds_data_allowed?(dnssec_data)
    ds_data_with_keys_allowed?(dnssec_data)
    key_data_allowed?(dnssec_data)

    errors.empty?
  end

  def ds_data_allowed?(dnssec_data)
    return if (dnssec_data[:ds_data].any? && Setting.ds_data_allowed) || dnssec_data[:ds_data].empty?
    errors.add(:base, :ds_data_not_allowed)
  end

  def ds_data_with_keys_allowed?(dnssec_data)
    dnssec_data[:ds_data].each do |ds_data|
      if key_data?(ds_data) && !Setting.ds_data_with_key_allowed
        errors.add(:base, :ds_data_with_key_not_allowed)
        return
      end
    end
  end

  def key_data_allowed?(dnssec_data)
    return if (dnssec_data[:key_data].any? && Setting.key_data_allowed) || dnssec_data[:key_data].empty?
    errors.add(:base, :key_data_not_allowed)
  end

  def key_data?(data)
    key_data_attrs = [:public_key, :alg, :protocol, :flags]
    (data.keys & key_data_attrs).any?
  end

  def detach_dnskeys(dnssec_data)
    return false unless validate_dnssec_data(dnssec_data)

    to_delete = []
    dnssec_data[:ds_data].each do |x|
      ds = dnskeys.where(ds_key_tag: x[:ds_key_tag])
      if ds.blank?
        add_epp_error('2303', 'keyTag', x[:key_tag], [:dnskeys, :not_found])
      else
        to_delete << ds
      end
    end

    to_delete = []
    dnssec_data[:key_data].each do |x|
      ds = dnskeys.where(public_key: x[:public_key])
      if ds.blank?
        add_epp_error('2303', 'publicKey', x[:public_key], [:dnskeys, :not_found])
      else
        to_delete << ds
      end
    end

    dnskeys.delete(to_delete)
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

  # rubocop: disable Metrics/PerceivedComplexity
  # rubocop: disable Metrics/MethodLength
  # rubocop: disable Metrics/CyclomaticComplexity
  def transfer(params)
    return false unless authenticate(params[:pw])

    pt = pending_transfer
    if pt && params[:action] == 'approve'
      return approve_pending_transfer(params[:current_user])
    end

    if !pt && params[:action] == 'query'
      return false unless can_be_transferred_to?(params[:current_user].registrar)
    end

    return true if pt

    if Setting.transfer_wait_time > 0
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

      generate_auth_info

      self.registrar = params[:current_user].registrar
      save
    end
  end
  # rubocop: enable Metrics/PerceivedComplexity
  # rubocop: enable Metrics/MethodLength
  # rubocop: enable Metrics/CyclomaticComplexity

  def approve_pending_transfer(current_user)
    pt = pending_transfer
    if current_user.registrar != pt.transfer_from
      add_epp_error('2304', nil, nil, I18n.t('shared.transfer_can_be_approved_only_by_current_registrar'))
      return false
    end

    pt.update(
      status: DomainTransfer::CLIENT_APPROVED,
      transferred_at: Time.zone.now
    )

    generate_auth_info

    self.registrar = pt.transfer_to
    save
  end

  ### VALIDATIONS ###

  def validate_exp_dates(cur_exp_date)
    return if cur_exp_date.to_date == valid_to
    add_epp_error('2306', 'curExpDate', cur_exp_date, I18n.t('errors.messages.epp_exp_dates_do_not_match'))
  end

  ### ABILITIES ###
  def can_be_deleted?
    begin
      errors.add(:base, :domain_status_prohibits_operation)
      return false
    end if (domain_statuses.pluck(:value) & %W(
      #{DomainStatus::CLIENT_DELETE_PROHIBITED}
    )).any?

    true
  end

  def can_be_transferred_to?(new_registrar)
    if new_registrar == registrar
      errors.add(:base, :domain_already_belongs_to_the_querying_registrar)
      return false
    end
    true
  end

  ## SHARED

  # For domain transfer
  def authenticate(pw)
    errors.add(:auth_info, :wrong_pw) if pw != auth_info
    errors.empty?
  end

  class << self
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

    def parse_owner_contact_from_frame(parsed_frame)
      parsed_frame.css('registrant').first.try(:text)
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

    def parse_dnskeys_from_frame(parsed_frame)
      res = { ds_data: [], key_data: [] }

      res[:max_sig_life] = parsed_frame.css('maxSigLife').first.try(:text)

      res = parse_ds_data_from_frame(parsed_frame, res)
      parse_key_data_from_frame(parsed_frame, res)
    end

    def parse_key_data_from_frame(parsed_frame, res)
      parsed_frame.xpath('keyData').each do |x|
        res[:key_data] << {
          flags: x.css('flags').first.try(:text),
          protocol: x.css('protocol').first.try(:text),
          alg: x.css('alg').first.try(:text),
          public_key: x.css('pubKey').first.try(:text)
        }
      end

      res
    end

    def parse_ds_data_from_frame(parsed_frame, res)
      parsed_frame.css('dsData').each do |x|
        data = {
          ds_key_tag: x.css('keyTag').first.try(:text),
          ds_alg: x.css('alg').first.try(:text),
          ds_digest_type: x.css('digestType').first.try(:text),
          ds_digest: x.css('digest').first.try(:text)
        }

        kd = x.css('keyData').first
        data.merge!({
          flags: kd.css('flags').first.try(:text),
          protocol: kd.css('protocol').first.try(:text),
          alg: kd.css('alg').first.try(:text),
          public_key: kd.css('pubKey').first.try(:text)
        }) if kd

        res[:ds_data] << data
      end

      res
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
# rubocop: enable Metrics/ClassLength
