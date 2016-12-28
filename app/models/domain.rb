# rubocop: disable Metrics/ClassLength
class Domain < ActiveRecord::Base
  include UserEvents
  include Versions # version/domain_version.rb
  include Statuses
  include Concerns::Domain::Expirable

  has_paper_trail class_name: "DomainVersion", meta: { children: :children_log }

  attr_accessor :roles

  attr_accessor :legal_document_id

  alias_attribute :on_hold_time, :outzone_at
  alias_attribute :force_delete_time, :force_delete_at
  alias_attribute :outzone_time, :outzone_at
  alias_attribute :delete_time, :delete_at

  # TODO: whois requests ip whitelist for full info for own domains and partial info for other domains
  # TODO: most inputs should be trimmed before validatation, probably some global logic?

  belongs_to :registrar
  belongs_to :registrant
  # TODO: should we user validates_associated :registrant here?

  has_many :admin_domain_contacts
  accepts_nested_attributes_for :admin_domain_contacts,  allow_destroy: true, reject_if: :admin_change_prohibited?
  has_many :tech_domain_contacts
  accepts_nested_attributes_for :tech_domain_contacts, allow_destroy: true, reject_if: :tech_change_prohibited?

  def registrant_change_prohibited?
    statuses.include? DomainStatus::SERVER_REGISTRANT_CHANGE_PROHIBITED
  end


  # NB! contacts, admin_contacts, tech_contacts are empty for a new record
  has_many :domain_contacts, dependent: :destroy
  has_many :contacts, through: :domain_contacts, source: :contact
  has_many :admin_contacts, through: :admin_domain_contacts, source: :contact
  has_many :tech_contacts, through: :tech_domain_contacts, source: :contact
  has_many :nameservers, dependent: :destroy

  accepts_nested_attributes_for :nameservers, allow_destroy: true,
                                              reject_if: proc { |attrs| attrs[:hostname].blank? }

  has_many :domain_statuses, dependent: :destroy
  accepts_nested_attributes_for :domain_statuses, allow_destroy: true,
                                                  reject_if: proc { |attrs| attrs[:value].blank? }

  has_many :domain_transfers, dependent: :destroy

  has_many :dnskeys, dependent: :destroy

  has_many :keyrelays
  has_one  :whois_record # destroyment will be done in after_commit

  accepts_nested_attributes_for :dnskeys, allow_destroy: true

  has_many :legal_documents, as: :documentable
  accepts_nested_attributes_for :legal_documents, reject_if: proc { |attrs| attrs[:body].blank? }

  delegate :name,    to: :registrant, prefix: true
  delegate :code,    to: :registrant, prefix: true
  delegate :ident,   to: :registrant, prefix: true
  delegate :email,   to: :registrant, prefix: true
  delegate :phone,   to: :registrant, prefix: true
  delegate :street,  to: :registrant, prefix: true
  delegate :city,    to: :registrant, prefix: true
  delegate :zip,     to: :registrant, prefix: true
  delegate :state,   to: :registrant, prefix: true
  delegate :country, to: :registrant, prefix: true

  delegate :name,   to: :registrar, prefix: true
  delegate :street, to: :registrar, prefix: true

  after_initialize do
    self.pending_json = {} if pending_json.blank?
    self.statuses = [] if statuses.nil?
    self.status_notes = {} if status_notes.nil?
  end

  before_create :generate_auth_info
  before_create -> { self.reserved = in_reserved_list?; nil }

  before_save :manage_automatic_statuses
  before_save :touch_always_version
  def touch_always_version
    self.updated_at = Time.zone.now
  end

  before_update :manage_statuses
  def manage_statuses
    return unless registrant_id_changed? # rollback has not yet happened
    pending_update! if registrant_verification_asked?
    true
  end

  after_commit :update_whois_record

  after_create :update_reserved_domains
  def update_reserved_domains
    ReservedDomain.new_password_for(name) if in_reserved_list?
  end

  validates :name_dirty, domain_name: true, uniqueness: true
  validates :puny_label, length: { maximum: 63 }
  validates :period, numericality: { only_integer: true }
  validates :registrant, :registrar, presence: true

  validate :validate_period
  validate :validate_reservation
  def validate_reservation
    return if persisted? || !in_reserved_list?

    if reserved_pw.blank?
      errors.add(:base, :required_parameter_missing_reserved)
      return false
    end

    return if ReservedDomain.pw_for(name) == reserved_pw
    errors.add(:base, :invalid_auth_information_reserved)
  end

  validate :status_is_consistant
  def status_is_consistant
      has_error = (statuses.include?(DomainStatus::SERVER_HOLD) && statuses.include?(DomainStatus::SERVER_MANUAL_INZONE))
      unless has_error
        if (statuses & [DomainStatus::PENDING_DELETE_CONFIRMATION, DomainStatus::PENDING_DELETE, DomainStatus::FORCE_DELETE]).any?
          has_error = statuses.include? DomainStatus::SERVER_DELETE_PROHIBITED
        end
      end
      errors.add(:domains, I18n.t(:object_status_prohibits_operation)) if has_error
  end

  attr_accessor :is_admin

  validate :check_permissions, :unless => :is_admin
  def check_permissions
    return unless force_delete?
    errors.add(:base, I18n.t(:object_status_prohibits_operation))
    false
  end

  validates :nameservers, domain_nameserver: {
    min: -> { Setting.ns_min_count },
    max: -> { Setting.ns_max_count }
  }

  validates :dnskeys, object_count: {
    min: -> { Setting.dnskeys_min_count },
    max: -> { Setting.dnskeys_max_count }
  }

  validates :admin_domain_contacts, object_count: {
    min: -> { Setting.admin_contacts_min_count },
    max: -> { Setting.admin_contacts_max_count }
  }

  validates :tech_domain_contacts, object_count: {
    min: -> { Setting.tech_contacts_min_count },
    max: -> { Setting.tech_contacts_max_count }
  }

  validates :nameservers, uniqueness_multi: {
    attribute: 'hostname'
  }

  validates :tech_domain_contacts, uniqueness_multi: {
    attribute: 'contact_code_cache'
  }

  validates :admin_domain_contacts, uniqueness_multi: {
    attribute: 'contact_code_cache'
  }

  validates :domain_statuses, uniqueness_multi: {
    attribute: 'value'
  }

  validates :dnskeys, uniqueness_multi: {
    attribute: 'public_key'
  }

  validate :validate_nameserver_ips

  validate :statuses_uniqueness
  def statuses_uniqueness
    return if statuses.uniq == statuses
    errors.add(:statuses, :taken)
  end

  attr_accessor :registrant_typeahead, :update_me, :deliver_emails,
    :epp_pending_update, :epp_pending_delete, :reserved_pw

  def subordinate_nameservers
    nameservers.select { |x| x.hostname.end_with?(name) }
  end

  def delegated_nameservers
    nameservers.select { |x| !x.hostname.end_with?(name) }
  end

  def admin_change_prohibited?
    statuses.include? DomainStatus::SERVER_ADMIN_CHANGE_PROHIBITED
  end

  def tech_change_prohibited?
    statuses.include? DomainStatus::SERVER_TECH_CHANGE_PROHIBITED
  end

  def self.clean_expired_pendings
    ActiveSupport::Deprecation.instance.deprecation_warning(DomainCron, __method__)
    DomainCron.send(__method__)
  end

  def self.start_redemption_grace_period
    ActiveSupport::Deprecation.instance.deprecation_warning(DomainCron, __method__)
    DomainCron.send(__method__)
  end

  def self.start_delete_period
    ActiveSupport::Deprecation.instance.deprecation_warning(DomainCron, __method__)
    DomainCron.send(__method__)
  end

  def self.destroy_delete_candidates
    ActiveSupport::Deprecation.instance.deprecation_warning(DomainCron, __method__)
    DomainCron.send(__method__)
  end

  class << self
    def convert_period_to_time(period, unit)
      return (period.to_i / 365).years if unit == 'd'
      return (period.to_i / 12).years  if unit == 'm'
      return period.to_i.years         if unit == 'y'
    end

    def included
      includes(
        :registrant,
        :registrar,
        :nameservers,
        :whois_record,
        { tech_contacts: :registrar },
        { admin_contacts: :registrar }
      )
    end

    def nameserver_required?
      Setting.nameserver_required
    end
  end

  def name=(value)
    value.strip!
    value.downcase!
    self[:name] = SimpleIDN.to_unicode(value)
    self[:name_puny] = SimpleIDN.to_ascii(value)
    self[:name_dirty] = value
  end

  # find by internationalized domain name
  # internet domain name => ascii or puny, but db::domains.name is unicode
  def self.find_by_idn(name)
    domain = self.find_by_name name
    if domain.blank? && name.include?('-')
      unicode = SimpleIDN.to_unicode name # we have no index on domains.name_puny
      domain = self.find_by_name unicode
    end
    domain
  end

  def roid
    "EIS-#{id}"
  end

  def puny_label
    name_puny.to_s.split('.').first
  end

  def registrant_typeahead
    @registrant_typeahead || registrant.try(:name) || nil
  end

  def in_reserved_list?
    @in_reserved_list ||= ReservedDomain.by_domain(name).any?
  end

  def pending_transfer
    domain_transfers.find_by(status: DomainTransfer::PENDING)
  end

  def server_holdable?
    return false if statuses.include?(DomainStatus::SERVER_HOLD)
    return false if statuses.include?(DomainStatus::SERVER_MANUAL_INZONE)
    true
  end

  def delete_candidateable?
    return false if delete_at > Time.zone.now
    return false if statuses.include?(DomainStatus::DELETE_CANDIDATE)
    return false if statuses.include?(DomainStatus::SERVER_DELETE_PROHIBITED)
    true
  end

  def renewable?
    if Setting.days_to_renew_domain_before_expire != 0
      # if you can renew domain at days_to_renew before domain expiration
      if (expire_time.to_date - Date.today) + 1 > Setting.days_to_renew_domain_before_expire
        return false
      end
    end

    return false if statuses.include_any?(DomainStatus::DELETE_CANDIDATE, DomainStatus::PENDING_RENEW,
                                          DomainStatus::PENDING_TRANSFER, DomainStatus::PENDING_DELETE,
                                          DomainStatus::PENDING_UPDATE, DomainStatus::PENDING_DELETE_CONFIRMATION)
    true
  end

  def poll_message!(message_key)
    registrar.messages.create!(
      body: "#{I18n.t(message_key)}: #{name}",
      attached_obj_id: id,
      attached_obj_type: self.class.to_s
    )
  end

  def preclean_pendings
    self.registrant_verification_token = nil
    self.registrant_verification_asked_at = nil
  end

  def clean_pendings!
    preclean_pendings
    self.pending_json = {}
    statuses.delete(DomainStatus::PENDING_DELETE_CONFIRMATION)
    statuses.delete(DomainStatus::PENDING_UPDATE)
    statuses.delete(DomainStatus::PENDING_DELETE)
    status_notes[DomainStatus::PENDING_UPDATE] = ''
    status_notes[DomainStatus::PENDING_DELETE] = ''
    save
  end


  # state changes may be done low-level - no validation
  # in this metod we still save PaperTrail log.
  def clean_pendings_lowlevel
    statuses.delete(DomainStatus::PENDING_DELETE_CONFIRMATION)
    statuses.delete(DomainStatus::PENDING_UPDATE)
    statuses.delete(DomainStatus::PENDING_DELETE)

    status_notes[DomainStatus::PENDING_UPDATE] = ''
    status_notes[DomainStatus::PENDING_DELETE] = ''

    hash = {
        registrant_verification_token:    nil,
        registrant_verification_asked_at: nil,
        pending_json: {},
        status_notes: status_notes,
        statuses:     statuses.presence || [DomainStatus::OK],
        # need this column in order to update PaperTrail version properly
        updated_at:   Time.now.utc
    }

    # PaperTrail
    self.attributes = hash
    record_update
    clear_version_instance!
    reset_transaction_id

    update_columns(hash)
  end

  def pending_update!
    return true if pending_update?
    self.epp_pending_update = true # for epp

    return true unless registrant_verification_asked?
    pending_json_cache = pending_json
    token = registrant_verification_token
    asked_at = registrant_verification_asked_at
    new_registrant_id    = registrant.id
    new_registrant_email = registrant.email
    new_registrant_name  = registrant.name

    RegistrantChangeConfirmEmailJob.enqueue(id, new_registrant_id)
    RegistrantChangeNoticeEmailJob.enqueue(id, new_registrant_id)

    reload

    self.pending_json = pending_json_cache
    self.registrant_verification_token = token
    self.registrant_verification_asked_at = asked_at
    set_pending_update
    touch_always_version
    pending_json['new_registrant_id']    = new_registrant_id
    pending_json['new_registrant_email'] = new_registrant_email
    pending_json['new_registrant_name']  = new_registrant_name

    # This pending_update! method is triggered by before_update
    # Note, all before_save callbacks are executed before before_update,
    # thus automatic statuses has already executed by this point
    # and we need to trigger automatic statuses manually (second time).
    manage_automatic_statuses
  end

  # rubocop: disable Metrics/CyclomaticComplexity
  def registrant_update_confirmable?(token)
    return false if (statuses & [DomainStatus::FORCE_DELETE, DomainStatus::DELETE_CANDIDATE]).any?
    return false unless pending_update?
    return false unless registrant_verification_asked?
    return false unless registrant_verification_token == token
    true
  end

  def registrant_delete_confirmable?(token)
    return false unless pending_delete?
    return false unless registrant_verification_asked?
    return false unless registrant_verification_token == token
    true
  end
  # rubocop: enable Metrics/CyclomaticComplexity

  def force_deletable?
    !statuses.include?(DomainStatus::FORCE_DELETE)
  end

  def registrant_verification_asked?
    registrant_verification_asked_at.present? && registrant_verification_token.present?
  end

  def registrant_verification_asked!(frame_str, current_user_id)
    pending_json['frame'] = frame_str
    pending_json['current_user_id'] = current_user_id
    self.registrant_verification_asked_at = Time.zone.now
    self.registrant_verification_token = SecureRandom.hex(42)
  end

  def pending_delete!
    return true if pending_delete?
    self.epp_pending_delete = true # for epp

    # TODO: if this were to ever return true, that would be wrong. EPP would report sucess pending
    return true unless registrant_verification_asked?
    pending_delete_confirmation!
    save(validate: false) # should check if this did succeed

    DomainDeleteConfirmEmailJob.enqueue(id)
  end

  def cancel_pending_delete
    statuses.delete DomainStatus::PENDING_DELETE_CONFIRMATION
    statuses.delete DomainStatus::PENDING_DELETE
    self.delete_at = nil
  end

  def pricelist(operation, period_i = nil, unit = nil)
    period_i ||= period
    unit ||= period_unit

    # TODO: test if name.scan(/\.(.+)\z/).first.first is faster
    zone = name.split('.').drop(1).join('.')

    p = period_i / 365 if unit == 'd'
    p = period_i / 12 if unit == 'm'
    p = period_i if unit == 'y'

    Pricelist.pricelist_for(zone, operation, "#{p}year".pluralize(p))
  end

  ### VALIDATIONS ###

  def validate_nameserver_ips
    nameservers.to_a.reject(&:marked_for_destruction?).each do |ns|
      next unless ns.hostname.end_with?(".#{name}")
      next if ns.ipv4.present? || ns.ipv6.present?

      errors.add(:nameservers, :invalid) if errors[:nameservers].blank?
      ns.errors.add(:ipv4, :blank)
    end
  end

  def validate_period
    return unless period.present?
    if period_unit == 'd'
      valid_values = %w(365 730 1095)
    elsif period_unit == 'm'
      valid_values = %w(12 24 36)
    else
      valid_values = %w(1 2 3)
    end

    errors.add(:period, :out_of_range) unless valid_values.include?(period.to_s)
  end

  # used for highlighting form tabs
  def parent_valid?
    assoc_errors = errors.keys.select { |x| x.match(/\./) }
    (errors.keys - assoc_errors).empty?
  end

  ## SHARED

  def name_in_wire_format
    res = ''
    parts = name_puny.split('.')
    parts.each do |x|
      res += format('%02X', x.length) # length of label in hex
      res += x.each_byte.map { |b| format('%02X', b) }.join # label
    end

    res += '00'

    res
  end

  def to_s
    name
  end

  def pending_registrant
    return '' if pending_json.blank?
    return '' if pending_json['new_registrant_id'].blank?
    Registrant.find_by(id: pending_json['new_registrant_id'])
  end

  def generate_auth_info
    return if auth_info.present?
    generate_auth_info!
  end

  # rubocop:disable Lint/Loop
  def generate_auth_info!
    begin
      self.auth_info = SecureRandom.hex
    end while self.class.exists?(auth_info: auth_info)
  end
  # rubocop:enable Lint/Loop

  # rubocop:disable Metrics/AbcSize
  # rubocop:disable Metrics/MethodLength
  def set_force_delete
    self.statuses_backup = statuses
    statuses.delete(DomainStatus::CLIENT_DELETE_PROHIBITED)
    statuses.delete(DomainStatus::SERVER_DELETE_PROHIBITED)
    statuses.delete(DomainStatus::PENDING_UPDATE)
    statuses.delete(DomainStatus::PENDING_TRANSFER)
    statuses.delete(DomainStatus::PENDING_RENEW)
    statuses.delete(DomainStatus::PENDING_CREATE)

    statuses.delete(DomainStatus::FORCE_DELETE)
    statuses.delete(DomainStatus::SERVER_RENEW_PROHIBITED)
    statuses.delete(DomainStatus::SERVER_TRANSFER_PROHIBITED)
    statuses.delete(DomainStatus::SERVER_UPDATE_PROHIBITED)
    statuses.delete(DomainStatus::SERVER_MANUAL_INZONE)
    statuses.delete(DomainStatus::PENDING_DELETE)

    statuses << DomainStatus::FORCE_DELETE
    statuses << DomainStatus::SERVER_RENEW_PROHIBITED
    statuses << DomainStatus::SERVER_TRANSFER_PROHIBITED
    statuses << DomainStatus::SERVER_UPDATE_PROHIBITED
    statuses << DomainStatus::PENDING_DELETE

    if (statuses & [DomainStatus::SERVER_HOLD, DomainStatus::CLIENT_HOLD]).empty?
      statuses << DomainStatus::SERVER_MANUAL_INZONE
    end

    self.force_delete_at = (Time.zone.now + (Setting.redemption_grace_period.days + 1.day)).utc.beginning_of_day unless force_delete_at

    transaction do
      save!(validate: false)
      registrar.messages.create!(
        body: I18n.t('force_delete_set_on_domain', domain: name)
      )

      DomainDeleteForcedEmailJob.enqueue(id)

      return true
    end
    false
  end
  # rubocop: enable Metrics/MethodLength
  # rubocop:enable Metrics/AbcSize

  def unset_force_delete
    s = []
    s << DomainStatus::EXPIRED if statuses.include?(DomainStatus::EXPIRED)
    s << DomainStatus::SERVER_HOLD if statuses.include?(DomainStatus::SERVER_HOLD)
    s << DomainStatus::DELETE_CANDIDATE if statuses.include?(DomainStatus::DELETE_CANDIDATE)

    self.statuses = (statuses_backup + s).uniq

    self.force_delete_at = nil
    self.statuses_backup = []
    save(validate: false)
  end

  def set_graceful_expired
    self.outzone_at = expire_time + self.class.expire_warning_period
    self.delete_at = outzone_at + self.class.redemption_grace_period
    self.statuses |= [DomainStatus::EXPIRED]
  end

  def pending_update?
    statuses.include?(DomainStatus::PENDING_UPDATE) && !statuses.include?(DomainStatus::FORCE_DELETE)
  end

  # depricated not used, not valid
  def update_prohibited?
    pending_update_prohibited? && pending_delete_prohibited?
  end

  # public api
  def delete_prohibited?
    statuses.include?(DomainStatus::FORCE_DELETE)
  end

  # special handling for admin changing status
  def admin_status_update(update)
    # check for deleted status
    statuses.each do |s|
      unless update.include? s
        case s
          when DomainStatus::PENDING_DELETE
            self.delete_at = nil
          when DomainStatus::SERVER_MANUAL_INZONE # removal causes server hold to set
            self.outzone_at = Time.zone.now if self.force_delete_at.present?
          when DomainStatus::DomainStatus::EXPIRED # removal causes server hold to set
            self.outzone_at = self.expire_time + 15.day
          when DomainStatus::DomainStatus::SERVER_HOLD # removal causes server hold to set
            self.outzone_at = nil
        end
      end
    end
  end

  def pending_update_prohibited?
    (statuses_was & DomainStatus::UPDATE_PROHIBIT_STATES).present?
  end

  def set_pending_update
    if pending_update_prohibited?
      logger.info "DOMAIN STATUS UPDATE ISSUE ##{id}: PENDING_UPDATE not allowed to set. [#{statuses}]"
      return nil
    end
    statuses << DomainStatus::PENDING_UPDATE
  end

  def pending_delete?
    (statuses & [DomainStatus::PENDING_DELETE_CONFIRMATION, DomainStatus::PENDING_DELETE]).any?
  end

  def pending_delete_confirmation?
    statuses.include? DomainStatus::PENDING_DELETE_CONFIRMATION
  end

  def pending_delete_confirmation!
    statuses << DomainStatus::PENDING_DELETE_CONFIRMATION unless pending_delete_prohibited?
  end

  def pending_delete_prohibited?
    (statuses_was & DomainStatus::DELETE_PROHIBIT_STATES).present?
  end

  # let's use positive method names
  def pending_deletable?
    !pending_delete_prohibited?
  end

  def set_pending_delete
    if pending_delete_prohibited?
      logger.info "DOMAIN STATUS UPDATE ISSUE ##{id}: PENDING_DELETE not allowed to set. [#{statuses}]"
      return nil
    end
    statuses << DomainStatus::PENDING_DELETE
  end

  def set_server_hold
    statuses << DomainStatus::SERVER_HOLD
    self.outzone_at = Time.current
  end

  # rubocop: disable Metrics/CyclomaticComplexity
  # rubocop: disable Metrics/PerceivedComplexity
  def manage_automatic_statuses
    if statuses.empty? && valid?
      statuses << DomainStatus::OK
    elsif statuses.length > 1 || !valid?
      statuses.delete(DomainStatus::OK)
    end

    p_d = statuses.include?(DomainStatus::PENDING_DELETE)
    s_h = (statuses & [DomainStatus::SERVER_MANUAL_INZONE, DomainStatus::SERVER_HOLD]).empty?
    statuses << DomainStatus::SERVER_HOLD if p_d && s_h

    if !self.class.nameserver_required?
      statuses << DomainStatus::INACTIVE if nameservers.empty?
      statuses.delete(DomainStatus::INACTIVE) if nameservers.size >= Setting.ns_min_count
    end
  end
  # rubocop: enable Metrics/CyclomaticComplexity
  # rubocop: enable Metrics/PerceivedComplexity

  def children_log
    log = HashWithIndifferentAccess.new
    log[:admin_contacts] = admin_contact_ids
    log[:tech_contacts]  = tech_contact_ids
    log[:nameservers]    = nameserver_ids
    log[:dnskeys]        = dnskey_ids
    log[:domain_statuses]= domain_status_ids
    log[:legal_documents]= [legal_document_id]
    log[:registrant]     = [registrant_id]
    log
  end

  def update_whois_record
    UpdateWhoisRecordJob.enqueue name, 'domain'
  end

  def status_notes_array=(notes)
    self.status_notes = {}
    notes ||= []
    statuses.each_with_index do |status, i|
      status_notes[status] = notes[i]
    end
  end

  def send_mail(action)
    DomainMailer.send(action, DomainMailModel.new(self).send(action)).deliver
  end

  def admin_contact_names
    admin_contacts.names
  end

  def admin_contact_emails
    admin_contacts.emails
  end

  def tech_contact_names
    tech_contacts.names
  end

  def nameserver_hostnames
    nameservers.hostnames
  end

  def primary_contact_emails
    (admin_contact_emails << registrant_email).uniq
  end

  def new_registrant_email
    pending_json['new_registrant_email']
  end

  def new_registrant_id
    pending_json['new_registrant_id']
  end

  def self.to_csv
    CSV.generate do |csv|
      csv << column_names
      all.each do |domain|
        csv << domain.attributes.values_at(*column_names)
      end
    end
  end

  def self.pdf(html)
    kit = PDFKit.new(html)
    kit.to_pdf
  end

  def self.expire_warning_period
    Setting.expire_warning_period.days
  end

  def self.redemption_grace_period
    Setting.redemption_grace_period.days
  end

  def self.outzone_candidates
    where("#{attribute_alias(:outzone_time)} < ?", Time.zone.now)
  end

  def self.delete_candidates
    where("#{attribute_alias(:delete_time)} < ?", Time.zone.now)
  end
end
# rubocop: enable Metrics/ClassLength
