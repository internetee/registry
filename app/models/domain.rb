class Domain < ApplicationRecord
  include UserEvents
  include Versions # version/domain_version.rb
  include Concerns::Domain::Expirable
  include Concerns::Domain::Activatable
  include Concerns::Domain::ForceDelete
  include Concerns::Domain::Discardable
  include Concerns::Domain::Deletable
  include Concerns::Domain::Transferable
  include Concerns::Domain::RegistryLockable
  include Concerns::Domain::Releasable

  has_paper_trail class_name: "DomainVersion", meta: { children: :children_log }

  attr_accessor :roles

  attr_accessor :legal_document_id

  alias_attribute :on_hold_time, :outzone_at
  alias_attribute :outzone_time, :outzone_at
  alias_attribute :auth_info, :transfer_code # Old attribute name; for PaperTrail

  # TODO: whois requests ip whitelist for full info for own domains and partial info for other domains
  # TODO: most inputs should be trimmed before validatation, probably some global logic?

  belongs_to :registrar, required: true
  belongs_to :registrant, required: true
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
  has_many :nameservers, dependent: :destroy, inverse_of: :domain

  accepts_nested_attributes_for :nameservers, allow_destroy: true,
                                              reject_if: proc { |attrs| attrs[:hostname].blank? }

  has_many :transfers, class_name: 'DomainTransfer', dependent: :destroy

  has_many :dnskeys, dependent: :destroy

  has_one  :whois_record # destroyment will be done in after_commit

  accepts_nested_attributes_for :dnskeys, allow_destroy: true

  has_many :legal_documents, as: :documentable
  accepts_nested_attributes_for :legal_documents, reject_if: proc { |attrs| attrs[:body].blank? }
  has_many :registrant_verifications, dependent: :destroy

  after_initialize do
    self.pending_json = {} if pending_json.blank?
    self.statuses = [] if statuses.nil?
    self.status_notes = {} if status_notes.nil?
  end

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

  after_commit :update_whois_record, unless: 'domain_name.at_auction?'

  after_create :update_reserved_domains
  def update_reserved_domains
    ReservedDomain.new_password_for(name) if in_reserved_list?
  end

  validates :name_dirty, domain_name: true, uniqueness: true
  validates :puny_label, length: { maximum: 63 }
  validates :period, presence: true, numericality: { only_integer: true }
  validates :transfer_code, presence: true

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

  # Removed to comply new ForceDelete procedure
  # at https://github.com/internetee/registry/issues/1428#issuecomment-570561967
  #
  # validate :check_permissions, :unless => :is_admin
  # def check_permissions
  #   return unless force_delete_scheduled?
  #   errors.add(:base, I18n.t(:object_status_prohibits_operation))
  #   false
  # end

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

  validates :dnskeys, uniqueness_multi: {
    attribute: 'public_key'
  }

  validate :validate_nameserver_ips

  validate :statuses_uniqueness
  def statuses_uniqueness
    return if statuses.uniq == statuses
    errors.add(:statuses, :taken)
  end

  attr_accessor :registrant_typeahead, :update_me,
    :epp_pending_update, :epp_pending_delete, :reserved_pw

  self.ignored_columns = %w[legacy_id legacy_registrar_id legacy_registrant_id]

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

  class << self
    def nameserver_required?
      Setting.nameserver_required
    end

    def registrant_user_domains(registrant_user)
      from(
        "(#{registrant_user_domains_by_registrant(registrant_user).to_sql} UNION " \
        "#{registrant_user_domains_by_contact(registrant_user).to_sql}) AS domains"
      )
    end

    def registrant_user_direct_domains(registrant_user)
      from(
        "(#{registrant_user_direct_domains_by_registrant(registrant_user).to_sql} UNION " \
        "#{registrant_user_direct_domains_by_contact(registrant_user).to_sql}) AS domains"
      )
    end

    def registrant_user_administered_domains(registrant_user)
      from(
        "(#{registrant_user_domains_by_registrant(registrant_user).to_sql} UNION " \
        "#{registrant_user_domains_by_admin_contact(registrant_user).to_sql}) AS domains"
      )
    end

    private

    def registrant_user_domains_by_registrant(registrant_user)
      where(registrant: registrant_user.contacts)
    end

    def registrant_user_domains_by_contact(registrant_user)
      joins(:domain_contacts).where(domain_contacts: { contact_id: registrant_user.contacts })
    end

    def registrant_user_domains_by_admin_contact(registrant_user)
      joins(:domain_contacts).where(domain_contacts: { contact_id: registrant_user.contacts,
                                                       type: [AdminDomainContact.name] })
    end

    def registrant_user_direct_domains_by_registrant(registrant_user)
      where(registrant: registrant_user.direct_contacts)
    end

    def registrant_user_direct_domains_by_contact(registrant_user)
      joins(:domain_contacts).where(domain_contacts: { contact_id: registrant_user.direct_contacts })
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
    transfers.find_by(status: DomainTransfer::PENDING)
  end

  def server_holdable?
    return false if statuses.include?(DomainStatus::SERVER_HOLD)
    return false if statuses.include?(DomainStatus::SERVER_MANUAL_INZONE)
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

  def notify_registrar(message_key)
    registrar.notifications.create!(
      text: "#{I18n.t(message_key)}: #{name}",
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
    self.delete_date = nil
  end

  def pricelist(operation_category, period_i = nil, unit = nil)
    period_i ||= period
    unit ||= period_unit

    zone_name = name.split('.').drop(1).join('.')
    zone = DNS::Zone.find_by(origin: zone_name)

    duration = "P#{period_i}#{unit.upcase}"

    Billing::Price.price_for(zone, operation_category, duration)
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

  def set_graceful_expired
    self.outzone_at = expire_time + self.class.expire_warning_period
    self.delete_date = outzone_at + self.class.redemption_grace_period
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
            self.delete_date = nil
          when DomainStatus::SERVER_MANUAL_INZONE # removal causes server hold to set
            self.outzone_at = Time.zone.now if force_delete_scheduled?
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

  def manage_automatic_statuses
    if !self.class.nameserver_required?
      deactivate if nameservers.reject(&:marked_for_destruction?).empty?
      activate if nameservers.reject(&:marked_for_destruction?).size >= Setting.ns_min_count
    end

    cancel_force_delete if force_delete_scheduled? && pending_json['new_registrant_id']

    if statuses.empty? && valid?
      statuses << DomainStatus::OK
    elsif (statuses.length > 1 && active?) || !valid?
      statuses.delete(DomainStatus::OK)
    end

    p_d = statuses.include?(DomainStatus::PENDING_DELETE)
    s_h = (statuses & [DomainStatus::SERVER_MANUAL_INZONE, DomainStatus::SERVER_HOLD]).empty?
    statuses << DomainStatus::SERVER_HOLD if p_d && s_h
  end

  def children_log
    log = HashWithIndifferentAccess.new
    log[:admin_contacts] = admin_contact_ids
    log[:tech_contacts]  = tech_contact_ids
    log[:nameservers]    = nameserver_ids
    log[:dnskeys]        = dnskey_ids
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

  def primary_contact_emails
    (admin_contacts.emails + [registrant.email]).uniq
  end

  def force_delete_contact_emails
    (primary_contact_emails + tech_contacts.pluck(:email) +
      ["info@#{name}", "#{prepared_domain_name}@#{name}"]).uniq
  end

  def prepared_domain_name
    name.split('.')&.first
  end

  def new_registrant_email
    pending_json['new_registrant_email']
  end

  def new_registrant_id
    pending_json['new_registrant_id']
  end

  def as_json(_options)
    hash = super
    hash['auth_info'] = hash.delete('transfer_code') # API v1 requirement
    hash['valid_from'] = hash['registered_at'] # API v1 requirement
    hash.delete('statuses_before_force_delete')
    hash
  end

  def domain_name
    DNS::DomainName.new(name)
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

  def self.uses_zone?(zone)
    exists?(["name ILIKE ?", "%.#{zone.origin}"])
  end
end
