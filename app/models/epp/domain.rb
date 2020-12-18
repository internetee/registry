require 'deserializers/xml/legal_document'
require 'deserializers/xml/nameserver'
require 'deserializers/xml/domain_create'
require 'deserializers/xml/domain_update'
class Epp::Domain < Domain
  include EppErrors

  # TODO: remove this spagetti once data in production is correct.
  attr_accessor :is_renewal, :is_transfer

  before_validation :manage_permissions

  def manage_permissions
    return if is_admin # this bad hack for 109086524, refactor later
    return true if is_transfer || is_renewal
    return unless update_prohibited?

    stat = (statuses & (DomainStatus::UPDATE_PROHIBIT_STATES + DomainStatus::DELETE_PROHIBIT_STATES)).first
    add_epp_error('2304', 'status', stat, I18n.t(:object_status_prohibits_operation))
    throw(:abort)
  end

  after_validation :validate_contacts
  def validate_contacts
    return true if is_transfer

    ok = true
    active_admins = admin_domain_contacts.select { |x| !x.marked_for_destruction? }
    active_techs = tech_domain_contacts.select { |x| !x.marked_for_destruction? }

    # validate registrant here as well
    ([registrant] + active_admins + active_techs).each do |x|
      unless x.valid?
        add_epp_error('2304', nil, nil, I18n.t(:contact_is_not_valid, value: x.code))
        ok = false
      end
    end
    ok
  end

  def epp_code_map
    {
      '2002' => [ # Command use error
        %i[base domain_already_belongs_to_the_querying_registrar],
      ],
      '2003' => [ # Required parameter missing
        %i[registrant blank],
        %i[registrar blank],
        %i[base required_parameter_missing_reserved],
        %i[base required_parameter_missing_disputed],
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
        %i[transfer_code wrong_pw],
      ],
      '2202' => [
        %i[base invalid_auth_information_reserved],
        %i[base invalid_auth_information_disputed],
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
    tech_contacts << registrant if tech_domain_contacts.blank?
    admin_contacts << registrant if admin_domain_contacts.blank? && !registrant.org?
  end

  # Adding legal doc to domain and
  # if something goes wrong - raise Rollback error
  def add_legal_file_to_new frame
    legal_document_data = ::Deserializers::Xml::LegalDocument.new(frame).call
    return unless legal_document_data
    return if legal_document_data[:body].starts_with?(ENV['legal_documents_dir'])

    doc = LegalDocument.create(documentable_type: Domain, document_type: legal_document_data[:type],
                               body: legal_document_data[:body])
    self.legal_documents = [doc]

    frame.css("legalDocument").first.content = doc.path if doc&.persisted?
    self.legal_document_id = doc.id
  end

  def apply_pending_update!
    preclean_pendings
    user  = ApiUser.find(pending_json['current_user_id'])
    frame = pending_json['frame'] ? pending_json['frame'].with_indifferent_access : {}

    self.statuses.delete(DomainStatus::PENDING_UPDATE)
    self.upid = user.registrar.id if user.registrar
    self.up_date = Time.zone.now

    return unless Actions::DomainUpdate.new(self, frame, true).call

    clean_pendings!

    save!

    WhoisRecord.find_by(domain_id: id).save # need to reload model

    true
  end

  def apply_pending_delete!
    preclean_pendings
    statuses.delete(DomainStatus::PENDING_DELETE_CONFIRMATION)
    statuses.delete(DomainStatus::PENDING_DELETE)
    DomainDeleteMailer.accepted(self).deliver_now
    clean_pendings!
    set_pending_delete!
    true
  end

  def attach_legal_document(legal_document_data)
    return unless legal_document_data
    return if legal_document_data[:body].starts_with?(ENV['legal_documents_dir'])

    legal_documents.create(
      document_type: legal_document_data[:type],
      body: legal_document_data[:body]
    )
  end

  def epp_destroy(frame, user_id)
    if discarded?
      add_epp_error('2304', nil, nil, 'Object status prohibits operation')
      return
    end

    if doc = attach_legal_document(::Deserializers::Xml::LegalDocument.new(frame).call)
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
    unless pending_deletable?
      add_epp_error('2304', nil, nil, I18n.t(:object_status_prohibits_operation))
      return
    end

    self.delete_date = Time.zone.today + Setting.redemption_grace_period.days + 1.day
    set_pending_delete
    set_server_hold if server_holdable?
    save(validate: false)
  end

  ### RENEW ###

  def renew(cur_exp_date, period, unit = 'y')
    @is_renewal = true
    validate_exp_dates(cur_exp_date)

    add_renew_epp_errors unless renewable?

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
    self.delete_date = nil
    self.period = period
    self.period_unit = unit

    statuses.delete(DomainStatus::SERVER_HOLD)
    statuses.delete(DomainStatus::EXPIRED)
    statuses.delete(DomainStatus::SERVER_UPDATE_PROHIBITED)
    cancel_pending_delete

    save
  end

  def add_renew_epp_errors
    if renew_blocking_statuses.any? && !renewable?
      add_epp_error('2304', 'status', renew_blocking_statuses,
                    I18n.t('object_status_prohibits_operation'))
    end
  end

  ### TRANSFER ###

  def transfer(frame, action, current_user)
    if discarded?
      add_epp_error('2106', nil, nil, 'Object is not eligible for transfer')
      return
    end

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
      add_epp_error('2002', nil, nil, I18n.t(:domain_already_belongs_to_the_querying_registrar))
      return
    end

    transaction do
      dt = transfers.create!(
        transfer_requested_at: Time.zone.now,
        old_registrar: registrar,
        new_registrar: current_user.registrar
      )

      if dt.pending?
        registrar.notifications.create!(
          text: I18n.t('transfer_requested'),
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

      attach_legal_document(::Deserializers::Xml::LegalDocument.new(frame).call)
      save!(validate: false)

      return dt
    end
  end

  def approve_transfer(frame, current_user)
    pt = pending_transfer

    if current_user.registrar != pt.old_registrar
      add_epp_error('2304', nil, nil, I18n.t('transfer_can_be_approved_only_by_current_registrar'))
      return
    end

    transaction do
      pt.update!(
        status: DomainTransfer::CLIENT_APPROVED,
        transferred_at: Time.zone.now
      )

      transfer_contacts(pt.new_registrar)
      regenerate_transfer_code
      self.registrar = pt.new_registrar

      attach_legal_document(::Deserializers::Xml::LegalDocument.new(frame).call)
      save!(validate: false)
    end

    pt
  end

  def reject_transfer(frame, current_user)
    pt = pending_transfer

    if current_user.registrar != pt.old_registrar
      add_epp_error('2304', nil, nil, I18n.t('transfer_can_be_rejected_only_by_current_registrar'))
      return
    end

    transaction do
      pt.update!(
        status: DomainTransfer::CLIENT_REJECTED
      )

      attach_legal_document(::Deserializers::Xml::LegalDocument.new(frame).call)
      save!(validate: false)
    end

    pt
  end

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
    if disputed?
      errors.add(:base, :domain_status_prohibits_operation)
      return false
    end

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

    def check_availability(domain_names)
      domain_names = [domain_names] if domain_names.is_a?(String)

      result = []

      domain_names.each do |domain_name_as_string|
        domain_name_as_string.strip!
        domain_name_as_string.downcase!

        unless DomainNameValidator.validate_format(domain_name_as_string)
          result << { name: domain_name_as_string, avail: 0, reason: 'invalid format' }
          next
        end

        domain_name = DNS::DomainName.new(SimpleIDN.to_unicode(domain_name_as_string))

        if domain_name.unavailable?
          reason = I18n.t("errors.messages.epp_domain_#{domain_name.unavailability_reason}")
          result << { name: domain_name_as_string, avail: 0, reason: reason }
          next
        end

        result << { name: domain_name_as_string, avail: 1 }
      end

      result
    end
  end
end
