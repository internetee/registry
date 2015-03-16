# rubocop: disable Metrics/ClassLength
class Epp::Domain < Domain
  include EppErrors

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
        [:base, :ds_data_with_key_not_allowed],
        [:base, :ds_data_not_allowed],
        [:base, :key_data_not_allowed],
        [:period, :not_a_number],
        [:period, :not_an_integer]
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
        ],
        [:admin_contacts, :out_of_range,
         {
           min: Setting.admin_contacts_min_count,
           max: Setting.admin_contacts_max_count
         }
        ],
        [:tech_contacts, :out_of_range,
         {
           min: Setting.tech_contacts_min_count,
           max: Setting.tech_contacts_max_count
         }
        ]
      ],
      '2005' => [
        [:name_dirty, :invalid,  { obj: 'name', val: name_dirty }]
      ],
      '2201' => [
        [:auth_info, :wrong_pw]
      ]
    }
  end

  def self.new_from_epp(frame, current_user)
    domain = Epp::Domain.new
    domain.attributes = domain.attrs_from(frame, current_user)
    domain.attach_default_contacts
    domain
  end

  def attach_default_contacts
    if tech_domain_contacts.count.zero?
      attach_contact(DomainContact::TECH, owner_contact)
    end

    return unless admin_domain_contacts.count.zero? && owner_contact.priv?
    attach_contact(DomainContact::ADMIN, owner_contact)
  end

  def attach_contact(type, contact)
    domain_contacts.build(
      contact: contact, contact_type: DomainContact::TECH, contact_code_cache: contact.code
    ) if type.to_sym == :tech

    domain_contacts.build(
      contact: contact, contact_type: DomainContact::ADMIN, contact_code_cache: contact.code
    ) if type.to_sym == :admin
  end

  # rubocop: disable Metrics/PerceivedComplexity
  # rubocop: disable Metrics/CyclomaticComplexity
  # rubocop: disable Metrics/MethodLength
  def attrs_from(frame, current_user, action = nil)
    at = {}.with_indifferent_access

    code = frame.css('registrant').first.try(:text)
    if code.present?
      oc = Contact.find_by(code: code).try(:id)

      if oc
        at[:owner_contact_id] = oc
      else
        add_epp_error('2303', 'registrant', code, [:owner_contact, :not_found])
      end
    end

    at[:name] = frame.css('name').text if new_record?
    at[:registrar_id] = current_user.registrar.try(:id)
    at[:registered_at] = Time.now if new_record?

    period = frame.css('period').text
    at[:period] = (period.to_i == 0) ? 1 : period.to_i

    at[:period_unit] = Epp::Domain.parse_period_unit_from_frame(frame) || 'y'

    at[:nameservers_attributes] = nameservers_attrs(frame, action)
    at[:domain_contacts_attributes] = domain_contacts_attrs(frame, action)
    at[:domain_statuses_attributes] = domain_statuses_attrs(frame, action)

    if new_record?
      dnskey_frame = frame.css('extension create')
    else
      dnskey_frame = frame
    end

    at[:dnskeys_attributes] = dnskeys_attrs(dnskey_frame, action)
    at[:legal_documents_attributes] = legal_document_from(frame)

    at
  end
  # rubocop: enable Metrics/PerceivedComplexity
  # rubocop: enable Metrics/CyclomaticComplexity
  # rubocop: enable Metrics/MethodLength

  def nameservers_attrs(frame, action)
    ns_list = nameservers_from(frame)

    if action == 'rem'
      to_destroy = []
      ns_list.each do |ns_attrs|
        nameserver = nameservers.where(ns_attrs).try(:first)
        if nameserver.blank?
          add_epp_error('2303', 'hostAttr', ns_attrs[:hostname], [:nameservers, :not_found])
        else
          to_destroy << {
            id: nameserver.id,
            _destroy: 1
          }
        end
      end

      return to_destroy
    else
      return ns_list
    end
  end

  def nameservers_from(frame)
    res = []
    frame.css('hostAttr').each do |x|
      host_attr = {
        hostname: x.css('hostName').first.try(:text),
        ipv4: x.css('hostAddr[ip="v4"]').first.try(:text),
        ipv6: x.css('hostAddr[ip="v6"]').first.try(:text)
      }

      res << host_attr.delete_if { |_k, v| v.blank? }
    end

    res
  end

  def domain_contacts_attrs(frame, action)
    contact_list = domain_contact_list_from(frame, action)

    if action == 'rem'
      to_destroy = []
      contact_list.each do |dc|
        domain_contact_id = domain_contacts.find_by(
          contact_id: dc[:contact_id],
          contact_type: dc[:contact_type]
        ).try(:id)

        unless domain_contact_id
          add_epp_error('2303', 'contact', dc[:contact_code_cache], [:domain_contacts, :not_found])
          next
        end

        to_destroy << {
          id: domain_contact_id,
          _destroy: 1
        }
      end

      return to_destroy
    else
      return contact_list
    end
  end

  def domain_contact_list_from(frame, action)
    res = []
    frame.css('contact').each do |x|
      c = Contact.find_by(code: x.text)

      unless c
        add_epp_error('2303', 'contact', x.text, [:domain_contacts, :not_found])
        next
      end

      if action != 'rem'
        if x['type'] == 'admin' && c.bic?
          add_epp_error('2306', 'contact', x.text, [:domain_contacts, :admin_contact_can_be_only_citizen])
          next
        end
      end

      res << {
        contact_id: Contact.find_by(code: x.text).try(:id),
        contact_type: x['type'],
        contact_code_cache: x.text
      }
    end

    res
  end

  # rubocop: disable Metrics/PerceivedComplexity
  # rubocop: disable Metrics/CyclomaticComplexity
  def dnskeys_attrs(frame, action)
    if frame.css('dsData').any? && !Setting.ds_data_allowed
      errors.add(:base, :ds_data_not_allowed)
    end

    if frame.xpath('keyData').any? && !Setting.key_data_allowed
      errors.add(:base, :key_data_not_allowed)
    end

    res = ds_data_from(frame)
    dnskeys_list = key_data_from(frame, res)

    if action == 'rem'
      to_destroy = []
      dnskeys_list.each do |x|
        dk = dnskeys.find_by(public_key: x[:public_key])

        unless dk
          add_epp_error('2303', 'publicKey', x[:public_key], [:dnskeys, :not_found])
          next
        end

        to_destroy << {
          id: dk.id,
          _destroy: 1
        }
      end

      return to_destroy
    else
      return dnskeys_list
    end
  end
  # rubocop: enable Metrics/PerceivedComplexity
  # rubocop: enable Metrics/CyclomaticComplexity

  def key_data_from(frame, res)
    frame.xpath('keyData').each do |x|
      res << {
        flags: x.css('flags').first.try(:text),
        protocol: x.css('protocol').first.try(:text),
        alg: x.css('alg').first.try(:text),
        public_key: x.css('pubKey').first.try(:text),
        ds_alg: 3,
        ds_digest_type: Setting.ds_algorithm
      }
    end

    res
  end

  def ds_data_from(frame)
    res = []
    frame.css('dsData').each do |x|
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

      res << data
    end

    res
  end

  def domain_statuses_attrs(frame, action)
    status_list = domain_status_list_from(frame)

    if action == 'rem'
      to_destroy = []
      status_list.each do |x|
        status = domain_statuses.find_by(value: x[:value])
        if status.blank?
          add_epp_error('2303', 'status', x[:value], [:domain_statuses, :not_found])
        else
          to_destroy << {
            id: status.id,
            _destroy: 1
          }
        end
      end

      return to_destroy
    else
      return status_list
    end
  end

  def domain_status_list_from(frame)
    status_list = []

    frame.css('status').each do |x|
      unless DomainStatus::CLIENT_STATUSES.include?(x['s'])
        add_epp_error('2303', 'status', x['s'], [:domain_statuses, :not_found])
        next
      end

      status_list << {
        value: x['s'],
        description: x.text
      }
    end

    status_list
  end

  def legal_document_from(frame)
    ld = frame.css('legalDocument').first
    return [] unless ld

    [{
      body: ld.text,
      document_type: ld['type']
    }]
  end

  def update(frame, current_user)
    return super if frame.blank?
    at = {}.with_indifferent_access
    at.deep_merge!(attrs_from(frame.css('chg'), current_user))
    at.deep_merge!(attrs_from(frame.css('rem'), current_user, 'rem'))

    at_add = attrs_from(frame.css('add'), current_user)
    at[:nameservers_attributes] += at_add[:nameservers_attributes]
    at[:domain_contacts_attributes] += at_add[:domain_contacts_attributes]
    at[:dnskeys_attributes] += at_add[:dnskeys_attributes]
    at[:domain_statuses_attributes] += at_add[:domain_statuses_attributes]

    errors.empty? && super(at)
  end

  def attach_legal_document(legal_document_data)
    return unless legal_document_data

    legal_documents.build(
      document_type: legal_document_data[:type],
      body: legal_document_data[:body]
    )
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
  # rubocop: disable Metrics/CyclomaticComplexity
  def transfer(frame, action, current_user)
    case action
    when 'query'
      return pending_transfer if pending_transfer
      return query_transfer(frame, current_user)
    when 'approve'
      return approve_transfer(frame, current_user) if pending_transfer
    when 'reject'
      return reject_transfer(frame, current_user) if pending_transfer
    end
    add_epp_error('2303', nil, nil, I18n.t('pending_transfer_was_not_found'))
  end

  # TODO: Eager load problems here. Investigate how it's possible not to query contact again
  # Check if versioning works with update_column
  def transfer_contacts(registrar_id)
    transfer_owner_contact(registrar_id)
    transfer_domain_contacts(registrar_id)
  end

  def transfer_owner_contact(registrar_id)
    is_other_domains_contact = DomainContact.where('contact_id = ? AND domain_id != ?', owner_contact_id, id).count > 0
    if owner_contact.domains_owned.count > 1 || is_other_domains_contact
      # copy contact
      c = Contact.find(owner_contact_id) # n+1 workaround
      oc = c.deep_clone include: [:statuses, :address]
      oc.code = nil
      oc.registrar_id = registrar_id
      oc.save!
      self.owner_contact_id = oc.id
    else
      # transfer contact
      owner_contact.update_column(:registrar_id, registrar_id) # n+1 workaround
    end
  end

  def transfer_domain_contacts(registrar_id)
    copied_ids = []
    contacts.each do |c|
      next if copied_ids.include?(c.id)

      is_other_domains_contact = DomainContact.where('contact_id = ? AND domain_id != ?', c.id, id).count > 0
      # if contact used to be owner contact but was copied, then contact must be transferred
      # (owner_contact_id_was != c.id)
      if c.domains.count > 1 || is_other_domains_contact
        # copy contact
        if owner_contact_id_was == c.id # owner contact was copied previously, do not copy it again
          oc = OpenStruct.new(id: owner_contact_id)
        else
          old_contact = Contact.find(c.id) # n+1 workaround
          oc = old_contact.deep_clone include: [:statuses, :address]
          oc.code = nil
          oc.registrar_id = registrar_id
          oc.save!
        end

        domain_contacts.where(contact_id: c.id).update_all({ contact_id: oc.id }) # n+1 workaround
        copied_ids << c.id
      else
        # transfer contact
        c.update_column(:registrar_id, registrar_id) # n+1 workaround
      end
    end
  end
  # rubocop: enable Metrics/PerceivedComplexity
  # rubocop: enable Metrics/CyclomaticComplexity

  # rubocop: disable Metrics/MethodLength
  def query_transfer(frame, current_user)
    return false unless can_be_transferred_to?(current_user.registrar)

    transaction do
      begin
        dt = domain_transfers.create!(
            transfer_requested_at: Time.zone.now,
            transfer_to: current_user.registrar,
            transfer_from: registrar
          )

        if dt.pending?
          registrar.messages.create!(
            body: I18n.t('transfer_requested'),
            attached_obj_id: dt.id,
            attached_obj_type: dt.class.to_s
          )
        end

        if dt.approved?
          transfer_contacts(current_user.registrar_id)
          generate_auth_info
          self.registrar = current_user.registrar
        end

        attach_legal_document(self.class.parse_legal_document_from_frame(frame))
        save!(validate: false)

        return dt
      rescue => _e
        add_epp_error('2306', nil, nil, I18n.t('action_failed_due_to_server_error'))
        raise ActiveRecord::Rollback
      end
    end
  end
  # rubocop: enable Metrics/MethodLength

  def approve_transfer(frame, current_user)
    pt = pending_transfer
    if current_user.registrar != pt.transfer_from
      add_epp_error('2304', nil, nil, I18n.t('transfer_can_be_approved_only_by_current_registrar'))
      return false
    end

    transaction do
      begin
        pt.update!(
          status: DomainTransfer::CLIENT_APPROVED,
          transferred_at: Time.zone.now
        )

        transfer_contacts(pt.transfer_to_id)
        generate_auth_info
        self.registrar = pt.transfer_to

        attach_legal_document(self.class.parse_legal_document_from_frame(frame))
        save!(validate: false)
      rescue => _e
        add_epp_error('2306', nil, nil, I18n.t('action_failed_due_to_server_error'))
        raise ActiveRecord::Rollback
      end
    end

    pt
  end

  def reject_transfer(frame, current_user)
    pt = pending_transfer
    if current_user.registrar != pt.transfer_from
      add_epp_error('2304', nil, nil, I18n.t('transfer_can_be_rejected_only_by_current_registrar'))
      return false
    end

    transaction do
      begin
        pt.update!(
          status: DomainTransfer::CLIENT_REJECTED
        )

        attach_legal_document(self.class.parse_legal_document_from_frame(frame))
        save!(validate: false)
      rescue => _e
        add_epp_error('2306', nil, nil, I18n.t('action_failed_due_to_server_error'))
        raise ActiveRecord::Rollback
      end
    end

    pt
  end

  # rubocop:disable Metrics/MethodLength
  def keyrelay(parsed_frame, requester)
    if registrar == requester
      errors.add(:base, :domain_already_belongs_to_the_querying_registrar) and return false
    end

    abs_datetime = parsed_frame.css('absolute').text
    abs_datetime = DateTime.parse(abs_datetime) if abs_datetime.present?

    transaction do
      kr = keyrelays.build(
        pa_date: Time.now,
        key_data_flags: parsed_frame.css('flags').text,
        key_data_protocol: parsed_frame.css('protocol').text,
        key_data_alg: parsed_frame.css('alg').text,
        key_data_public_key: parsed_frame.css('pubKey').text,
        auth_info_pw: parsed_frame.css('pw').text,
        expiry_relative: parsed_frame.css('relative').text,
        expiry_absolute: abs_datetime,
        requester: requester,
        accepter: registrar
      )

      legal_document_data = self.class.parse_legal_document_from_frame(parsed_frame)
      if legal_document_data
        kr.legal_documents.build(
          document_type: legal_document_data[:type],
          body: legal_document_data[:body]
        )
      end

      kr.save

      return false unless valid?

      registrar.messages.create!(
        body: 'Key Relay action completed successfully.',
        attached_obj_type: kr.class.to_s,
        attached_obj_id: kr.id
      )
    end

    true
  end
  # rubocop:enable Metrics/MethodLength

  ### VALIDATIONS ###

  def validate_exp_dates(cur_exp_date)
    begin
      return if cur_exp_date.to_date == valid_to
    rescue
      add_epp_error('2306', 'curExpDate', cur_exp_date, I18n.t('errors.messages.epp_exp_dates_do_not_match'))
      return
    end
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
    def parse_period_unit_from_frame(parsed_frame)
      p = parsed_frame.css('period').first
      return nil unless p
      p[:unit]
    end

    def parse_legal_document_from_frame(parsed_frame)
      ld = parsed_frame.css('legalDocument').first
      return nil unless ld

      {
        body: ld.text,
        type: ld['type']
      }
    end

    def check_availability(domains)
      domains = [domains] if domains.is_a?(String)

      res = []
      domains.each do |x|
        x.strip!
        x.downcase!
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
