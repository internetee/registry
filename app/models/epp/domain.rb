class Epp::Domain < Domain
  include EppErrors

  # TODO: remove this spagetti once data in production is correct.
  attr_accessor :is_renewal, :is_transfer

  before_validation :manage_permissions

  def manage_permissions
    return if is_admin # this bad hack for 109086524, refactor later
    return true if is_transfer || is_renewal
    return unless update_prohibited? || delete_prohibited?
    stat = (statuses & (DomainStatus::UPDATE_PROHIBIT_STATES + DomainStatus::DELETE_PROHIBIT_STATES)).first
    add_epp_error('2304', 'status', stat, I18n.t(:object_status_prohibits_operation))
    false
  end

  after_validation :validate_contacts
  def validate_contacts
    return true if is_transfer

    ok = true
    active_admins = admin_domain_contacts.select { |x| !x.marked_for_destruction? }
    active_techs = tech_domain_contacts.select { |x| !x.marked_for_destruction? }

    # bullet workaround
    ac = active_admins.map { |x| Contact.find(x.contact_id) }
    tc = active_techs.map { |x| Contact.find(x.contact_id) }

    # validate registrant here as well
    ([registrant] + ac + tc).each do |x|
      unless x.valid?
        add_epp_error('2304', nil, nil, I18n.t(:contact_is_not_valid, value: x.code))
        ok = false
      end
    end
    ok
  end

  class << self
    def new_from_epp(frame, current_user)
      domain = Epp::Domain.new
      domain.attributes = domain.attrs_from(frame, current_user)
      domain.attach_default_contacts
      domain.registered_at = Time.zone.now

      period = domain.period.to_i
      plural_period_unit_name = (domain.period_unit == 'm' ? 'months' : 'years').to_sym
      expire_time = (Time.zone.now.advance(plural_period_unit_name => period) + 1.day).beginning_of_day
      domain.expire_time = expire_time

      domain
    end
  end

  def epp_code_map
    {
      '2002' => [ # Command use error
        [:base, :domain_already_belongs_to_the_querying_registrar]
      ],
      '2003' => [ # Required parameter missing
        [:registrant, :blank],
        [:registrar, :blank],
        [:base, :required_parameter_missing_reserved]
      ],
      '2004' => [ # Parameter value range error
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
      '2005' => [ # Parameter value syntax error
        [:name_dirty, :invalid, { obj: 'name', val: name_dirty }],
        [:puny_label, :too_long, { obj: 'name', val: name_puny }]
      ],
      '2201' => [ # Authorisation error
        [:transfer_code, :wrong_pw]
      ],
      '2202' => [
        [:base, :invalid_auth_information_reserved]
      ],
      '2302' => [ # Object exists
        [:name_dirty, :taken, { value: { obj: 'name', val: name_dirty } }],
        [:name_dirty, :reserved, { value: { obj: 'name', val: name_dirty } }],
        [:name_dirty, :blocked, { value: { obj: 'name', val: name_dirty } }]
      ],
      '2304' => [ # Object status prohibits operation
        [:base, :domain_status_prohibits_operation]
      ],
      '2306' => [ # Parameter policy error
        [:base, :ds_data_with_key_not_allowed],
        [:base, :ds_data_not_allowed],
        [:base, :key_data_not_allowed],
        [:period, :not_a_number],
        [:period, :not_an_integer],
        [:registrant, :cannot_be_missing]
      ],
      '2308' => [
        [:base, :domain_name_blocked, { value: { obj: 'name', val: name_dirty } }],
        [:nameservers, :out_of_range,
         {
           min: Setting.ns_min_count,
           max: Setting.ns_max_count
         }
        ],
      ]
    }
  end

  def attach_default_contacts
    return if registrant.blank?
    regt = Registrant.find(registrant.id) # temp for bullet
    tech_contacts << regt if tech_domain_contacts.blank?
    admin_contacts << regt if admin_domain_contacts.blank? && !regt.org?
  end

  def attrs_from(frame, current_user, action = nil)
    at = {}.with_indifferent_access

    registrant_frame = frame.css('registrant').first
    code = registrant_frame.try(:text)
    if code.present?
      if action == 'chg' && registrant_change_prohibited?
        add_epp_error('2304', "status", DomainStatus::SERVER_REGISTRANT_CHANGE_PROHIBITED, I18n.t(:object_status_prohibits_operation))
      end
      regt = Registrant.find_by(code: code)
      if regt
        at[:registrant_id] = regt.id
      else
        add_epp_error('2303', 'registrant', code, [:registrant, :not_found])
      end
    else
      add_epp_error('2306', nil, nil, [:registrant, :cannot_be_missing])
    end if registrant_frame


    at[:name] = frame.css('name').text if new_record?
    at[:registrar_id] = current_user.registrar.try(:id)
    at[:registered_at] = Time.zone.now if new_record?

    period = frame.css('period').text
    at[:period] = (period.to_i == 0) ? 1 : period.to_i

    at[:period_unit] = Epp::Domain.parse_period_unit_from_frame(frame) || 'y'

    at[:reserved_pw] = frame.css('reserved > pw').text

    # at[:statuses] = domain_statuses_attrs(frame, action)
    at[:nameservers_attributes] = nameservers_attrs(frame, action)
    at[:admin_domain_contacts_attributes] = admin_domain_contacts_attrs(frame, action)
    at[:tech_domain_contacts_attributes] = tech_domain_contacts_attrs(frame, action)

    pw = frame.css('authInfo > pw').text
    at[:transfer_code] = pw if pw.present?

    if new_record?
      dnskey_frame = frame.css('extension create')
    else
      dnskey_frame = frame
    end

    at[:dnskeys_attributes] = dnskeys_attrs(dnskey_frame, action)

    at
  end


  # Adding legal doc to domain and
  # if something goes wrong - raise Rollback error
  def add_legal_file_to_new frame
    legal_document_data = Epp::Domain.parse_legal_document_from_frame(frame)
    return unless legal_document_data

    doc = LegalDocument.create(
        documentable_type: Domain,
        document_type:     legal_document_data[:type],
        body:              legal_document_data[:body]
    )
    self.legal_documents = [doc]

    frame.css("legalDocument").first.content = doc.path if doc&.persisted?
    self.legal_document_id = doc.id
  end

  def nameservers_attrs(frame, action)
    ns_list = nameservers_from(frame)

    if action == 'rem'
      to_destroy = []
      ns_list.each do |ns_attrs|
        nameserver = nameservers.find_by_hash_params(ns_attrs).first
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
        ipv4: x.css('hostAddr[ip="v4"]').map(&:text).compact,
        ipv6: x.css('hostAddr[ip="v6"]').map(&:text).compact
      }

      res << host_attr.delete_if { |_k, v| v.blank? }
    end

    res
  end

  def admin_domain_contacts_attrs(frame, action)
    admin_attrs = domain_contact_attrs_from(frame, action, 'admin')

    if admin_attrs.present? && admin_change_prohibited?
      add_epp_error('2304', 'admin', DomainStatus::SERVER_ADMIN_CHANGE_PROHIBITED, I18n.t(:object_status_prohibits_operation))
      return []
    end

    case action
    when 'rem'
      return destroy_attrs(admin_attrs, admin_domain_contacts)
    else
      return admin_attrs
    end
  end

  def tech_domain_contacts_attrs(frame, action)
    tech_attrs = domain_contact_attrs_from(frame, action, 'tech')

    if tech_attrs.present? && tech_change_prohibited?
      add_epp_error('2304', 'tech', DomainStatus::SERVER_TECH_CHANGE_PROHIBITED, I18n.t(:object_status_prohibits_operation))
      return []
    end

    case action
    when 'rem'
      return destroy_attrs(tech_attrs, tech_domain_contacts)
    else
      return tech_attrs
    end
  end

  def destroy_attrs(attrs, dcontacts)
    destroy_attrs = []
    attrs.each do |at|
      domain_contact_id = dcontacts.find_by(contact_id: at[:contact_id]).try(:id)

      unless domain_contact_id
        add_epp_error('2303', 'contact', at[:contact_code_cache], [:domain_contacts, :not_found])
        next
      end

      destroy_attrs << {
        id: domain_contact_id,
        _destroy: 1
      }
    end

    destroy_attrs
  end

  def domain_contact_attrs_from(frame, action, type)
    attrs = []
    frame.css('contact').each do |x|
      next if x['type'] != type

      c = Epp::Contact.find_by_epp_code(x.text)
      unless c
        add_epp_error('2303', 'contact', x.text, [:domain_contacts, :not_found])
        next
      end

      if action != 'rem'
        if x['type'] == 'admin' && c.org?
          add_epp_error('2306', 'contact', x.text, [:domain_contacts, :admin_contact_can_be_only_private_person])
          next
        end
      end

      attrs << {
        contact_id: c.id,
        contact_code_cache: c.code
      }
    end

    attrs
  end

  def dnskeys_attrs(frame, action)
    keys = []
    return keys if frame.blank?
    inf_data = DnsSecKeys.new(frame)

    if  action == 'rem' &&
        frame.css('rem > all').first.try(:text) == 'true'
      keys = inf_data.mark_destroy_all dnskeys
    else
      if Setting.key_data_allowed
        errors.add(:base, :ds_data_not_allowed) if inf_data.ds_data.present?
        keys = inf_data.key_data
      end
      if Setting.ds_data_allowed
        errors.add(:base, :key_data_not_allowed) if inf_data.key_data.present?
        keys = inf_data.ds_data
      end
      if action == 'rem'
        keys = inf_data.mark_destroy(dnskeys)
        add_epp_error('2303', nil, nil, [:dnskeys, :not_found]) if keys.include? nil
      end
    end
    errors.any? ? [] : keys
  end

  class DnsSecKeys
    def initialize(frame)
      @key_data = []
      @ds_data = []
      # schema validation prevents both in the same parent node
      if frame.css('dsData').present?
        ds_data_from frame
      else
        frame.css('keyData').each do |key|
          @key_data.append key_data_from(key)
        end
      end
    end

    attr_reader :key_data
    attr_reader :ds_data

    def mark_destroy_all(dns_keys)
      # if transition support required mark_destroy dns_keys when has ds/key values otherwise ...
      dns_keys.map { |inf_data| mark inf_data }
    end

    def mark_destroy(dns_keys)
      (ds_data.present? ? ds_filter(dns_keys) : kd_filter(dns_keys)).map do |inf_data|
        inf_data.blank? ? nil : mark(inf_data)
      end
    end

    private

    KEY_INTERFACE = {flags: 'flags', protocol: 'protocol', alg: 'alg', public_key: 'pubKey' }
    DS_INTERFACE  =
        { ds_key_tag:     'keyTag',
          ds_alg:         'alg',
          ds_digest_type: 'digestType',
          ds_digest:      'digest'
        }

    def xm_copy(frame, map)
      result = {}
      map.each do |key, elem|
        result[key] = frame.css(elem).first.try(:text)
      end
      result
    end

    def key_data_from(frame)
      xm_copy frame, KEY_INTERFACE
   end

    def ds_data_from(frame)
      frame.css('dsData').each do |ds_data|
        key = ds_data.css('keyData')
        ds = xm_copy ds_data, DS_INTERFACE
        ds.merge(key_data_from key) if key.present?
        @ds_data << ds
      end
    end

    def ds_filter(dns_keys)
      @ds_data.map do |ds|
        dns_keys.find_by(ds.slice(*DS_INTERFACE.keys))
      end
     end

    def kd_filter(dns_keys)
      @key_data.map do |key|
        dns_keys.find_by(key)
      end
    end

    def mark(inf_data)
      { id: inf_data.id, _destroy: 1 }
    end
  end

  def domain_statuses_attrs(frame, action)
    status_list = domain_status_list_from(frame)
    if action == 'rem'
      to_destroy = []
      status_list.each do |x|
        if statuses.include?(x)
          to_destroy << x
        else
          add_epp_error('2303', 'status', x, [:domain_statuses, :not_found])
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

      status_list << x['s']
    end

    status_list
  end


  def update(frame, current_user, verify = true)
    return super if frame.blank?

    check_discarded

    at = {}.with_indifferent_access
    at.deep_merge!(attrs_from(frame.css('chg'), current_user, 'chg'))
    at.deep_merge!(attrs_from(frame.css('rem'), current_user, 'rem'))

    if doc = attach_legal_document(Epp::Domain.parse_legal_document_from_frame(frame))
      frame.css("legalDocument").first.content = doc.path if doc&.persisted?
      self.legal_document_id = doc.id
    end

    at_add = attrs_from(frame.css('add'), current_user, 'add')
    at[:nameservers_attributes] += at_add[:nameservers_attributes]
    at[:admin_domain_contacts_attributes] += at_add[:admin_domain_contacts_attributes]
    at[:tech_domain_contacts_attributes] += at_add[:tech_domain_contacts_attributes]
    at[:dnskeys_attributes] += at_add[:dnskeys_attributes]
    at[:statuses] =
      statuses - domain_statuses_attrs(frame.css('rem'), 'rem') + domain_statuses_attrs(frame.css('add'), 'add')

    if errors.empty? && verify
      self.upid = current_user.registrar.id if current_user.registrar
      self.up_date = Time.zone.now
    end

    same_registrant_as_current = (registrant.code == frame.css('registrant').text)

    if !same_registrant_as_current && errors.empty? && verify &&
       Setting.request_confrimation_on_registrant_change_enabled &&
       frame.css('registrant').present? &&
       frame.css('registrant').attr('verified').to_s.downcase != 'yes'
      registrant_verification_asked!(frame.to_s, current_user.id)
    end

    self.deliver_emails = true # turn on email delivery for epp

    errors.empty? && super(at)
  end

  def apply_pending_update!
    preclean_pendings
    user  = ApiUser.find(pending_json['current_user_id'])
    frame = Nokogiri::XML(pending_json['frame'])

    self.statuses.delete(DomainStatus::PENDING_UPDATE)
    self.upid = user.registrar.id if user.registrar
    self.up_date = Time.zone.now

    return unless update(frame, user, false)
    clean_pendings!

    save!

    WhoisRecord.find_by(domain_id: id).save # need to reload model

    true
  end

  def apply_pending_delete!
    preclean_pendings
    statuses.delete(DomainStatus::PENDING_DELETE_CONFIRMATION)
    statuses.delete(DomainStatus::PENDING_DELETE)
    DomainMailer.delete_confirmation(id, deliver_emails).deliver
    clean_pendings!
    set_pending_delete!
    true
  end

  def attach_legal_document(legal_document_data)
    return unless legal_document_data

    legal_documents.create(
      document_type: legal_document_data[:type],
      body: legal_document_data[:body]
    )
  end

  def epp_destroy(frame, user_id)
    check_discarded

    if doc = attach_legal_document(Epp::Domain.parse_legal_document_from_frame(frame))
      frame.css("legalDocument").first.content = doc.path if doc&.persisted?
    end

    if Setting.request_confirmation_on_domain_deletion_enabled &&
       frame.css('delete').children.css('delete').attr('verified').to_s.downcase != 'yes'

      registrant_verification_asked!(frame.to_s, user_id)
      pending_delete!
      manage_automatic_statuses
      true # aka 1001 pending_delete
    else
      set_pending_delete!
    end
  end

  def set_pending_delete!
    throw :epp_error, {
      code: '2304',
      msg: I18n.t(:object_status_prohibits_operation)
    } unless pending_deletable?

    self.delete_at = (Time.zone.now + (Setting.redemption_grace_period.days + 1.day)).utc.beginning_of_day
    set_pending_delete
    set_server_hold if server_holdable?
    save(validate: false)
  end

  def renew(cur_exp_date, period, unit = 'y')
    @is_renewal = true
    validate_exp_dates(cur_exp_date)

    add_epp_error('2105', nil, nil, I18n.t('object_is_not_eligible_for_renewal')) unless renewable?
    return false if errors.any?

    period = period.to_i
    plural_period_unit_name = (unit == 'm' ? 'months' : 'years').to_sym
    renewed_expire_time = valid_to.advance(plural_period_unit_name => period.to_i)

    max_reg_time = 11.years.from_now

    if renewed_expire_time >= max_reg_time
      add_epp_error('2105', nil, nil, I18n.t('epp.domains.object_is_not_eligible_for_renewal',
                                             max_date: max_reg_time.to_date.to_s(:db)))
      return false if errors.any?
    end

    self.expire_time = renewed_expire_time
    self.outzone_at = nil
    self.delete_at = nil
    self.period = period
    self.period_unit = unit

    statuses.delete(DomainStatus::SERVER_HOLD)
    statuses.delete(DomainStatus::EXPIRED)
    statuses.delete(DomainStatus::SERVER_UPDATE_PROHIBITED)

    save
  end

  ### TRANSFER ###

  def transfer(frame, action, current_user)
    check_discarded

    @is_transfer = true

    case action
    when 'query'
      return transfers.last if transfers.any?
    when 'request'
      return pending_transfer if pending_transfer
      return query_transfer(frame, current_user)
    when 'approve'
      return approve_transfer(frame, current_user) if pending_transfer
    when 'reject'
      return reject_transfer(frame, current_user) if pending_transfer
    end
  end

  def query_transfer(frame, current_user)
    if current_user.registrar == registrar
      throw :epp_error, {
        code: '2002',
        msg: I18n.t(:domain_already_belongs_to_the_querying_registrar)
      }
    end

    transaction do
      dt = transfers.create!(
        transfer_requested_at: Time.zone.now,
        old_registrar: registrar,
        new_registrar: current_user.registrar
      )

      if dt.pending?
        registrar.notifications.create!(
          body: I18n.t('transfer_requested'),
          attached_obj_id: dt.id,
          attached_obj_type: dt.class.to_s
        )
      end

      if dt.approved?
        dt.send(:notify_old_registrar)
        transfer_contacts(current_user.registrar)
        regenerate_transfer_code
        self.registrar = current_user.registrar
      end

      attach_legal_document(self.class.parse_legal_document_from_frame(frame))
      save!(validate: false)

      return dt
    end
  end

  def approve_transfer(frame, current_user)
    pt = pending_transfer
    if current_user.registrar != pt.old_registrar
      throw :epp_error, {
        msg: I18n.t('transfer_can_be_approved_only_by_current_registrar'),
        code: '2304'
      }
    end

    transaction do
      pt.update!(
        status: DomainTransfer::CLIENT_APPROVED,
        transferred_at: Time.zone.now
      )

      transfer_contacts(pt.new_registrar)
      regenerate_transfer_code
      self.registrar = pt.new_registrar

      attach_legal_document(self.class.parse_legal_document_from_frame(frame))
      save!(validate: false)
    end

    pt
  end

  def reject_transfer(frame, current_user)
    pt = pending_transfer
    if current_user.registrar != pt.old_registrar
      throw :epp_error, {
        msg: I18n.t('transfer_can_be_rejected_only_by_current_registrar'),
        code: '2304'
      }
    end

    transaction do
      pt.update!(
        status: DomainTransfer::CLIENT_REJECTED
      )

      attach_legal_document(self.class.parse_legal_document_from_frame(frame))
      save!(validate: false)
    end

    pt
  end

  def keyrelay(parsed_frame, requester)
    if registrar == requester
      errors.add(:base, :domain_already_belongs_to_the_querying_registrar) and return false
    end

    abs_datetime = parsed_frame.css('absolute').text
    abs_datetime = DateTime.zone.parse(abs_datetime) if abs_datetime.present?

    transaction do
      kr = keyrelays.build(
        pa_date: Time.zone.now,
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

      registrar.notifications.create!(
        body: 'Key Relay action completed successfully.',
        attached_obj_type: kr.class.to_s,
        attached_obj_id: kr.id
      )
    end

    true
  end

  ### VALIDATIONS ###

  def validate_exp_dates(cur_exp_date)
    begin
      return if cur_exp_date.to_date == valid_to.to_date
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
    end if (statuses & [DomainStatus::CLIENT_DELETE_PROHIBITED, DomainStatus::SERVER_DELETE_PROHIBITED]).any?

    true
  end

  ## SHARED

  # For domain transfer
  def authenticate(pw)
    errors.add(:transfer_code, :wrong_pw) if pw != transfer_code
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
      return nil if ld.text.starts_with?(ENV['legal_documents_dir']) # escape reloading
      return nil if ld.text.starts_with?('/home/') # escape reloading

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

        if ReservedDomain.pw_for(x).present?
          res << { name: x, avail: 0, reason: I18n.t('errors.messages.epp_domain_reserved') }
          next
        end

        if Domain.find_by_idn x
          res << { name: x, avail: 0, reason: 'in use' }
        else
          res << { name: x, avail: 1 }
        end
      end

      res
    end
  end

  private

  def check_discarded
    if discarded?
      throw :epp_error, {
        code: '2105',
        msg: I18n.t(:object_is_not_eligible_for_renewal),
      }
    end
  end
end
