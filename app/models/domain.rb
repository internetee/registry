class Domain < ApplicationRecord
  include UserEvents
  include Roids
  include Versions # version/domain_version.rb
  include Domain::Expirable
  include Domain::Activatable
  include Domain::ForceDelete
  include Domain::Discardable
  include Domain::Deletable
  include Domain::Transferable
  include Domain::RegistryLockable
  include Domain::Releasable
  include Domain::Disputable
  include Domain::BulkUpdatable
  include AgeValidation

  PERIODS = [
    ['3 months', '3m'],
    ['6 months', '6m'],
    ['9 months', '9m'],
    ['1 year', '1y'],
    ['2 years', '2y'],
    ['3 years', '3y'],
    ['4 years', '4y'],
    ['5 years', '5y'],
    ['6 years', '6y'],
    ['7 years', '7y'],
    ['8 years', '8y'],
    ['9 years', '9y'],
    ['10 years', '10y'],
  ].freeze

  attr_accessor :roles,
                :legal_document_id,
                :is_admin,
                :registrant_typeahead,
                :update_me,
                :epp_pending_update,
                :epp_pending_delete,
                :reserved_pw

  attr_accessor :skip_multiyears_expiration_email_validation

  alias_attribute :on_hold_time, :outzone_at
  alias_attribute :outzone_time, :outzone_at
  alias_attribute :auth_info, :transfer_code # Old attribute name; for PaperTrail
  alias_attribute :registered_at, :created_at

  store_accessor :json_statuses_history,
                 :force_delete_domain_statuses_history,
                 :admin_store_statuses_history

  # TODO: whois requests ip whitelist for full info for own domains and partial info for other domains
  # TODO: most inputs should be trimmed before validation, probably some global logic?

  belongs_to :registrar, required: true
  belongs_to :registrant, required: true
  # TODO: should we user validates_associated :registrant here?

  has_many :admin_domain_contacts
  accepts_nested_attributes_for :admin_domain_contacts,
                                allow_destroy: true, reject_if: :admin_change_prohibited?
  has_many :tech_domain_contacts
  accepts_nested_attributes_for :tech_domain_contacts,
                                allow_destroy: true, reject_if: :tech_change_prohibited?

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
  has_many :registrant_verifications, dependent: :destroy
  has_one :csync_record, dependent: :destroy

  attribute :skip_whois_record_update, :boolean, default: false

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
    return unless will_save_change_to_registrant_id? # rollback has not yet happened

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
    has_error = (hold_status? && statuses.include?(DomainStatus::SERVER_MANUAL_INZONE))
    if !has_error && statuses.include?(DomainStatus::PENDING_DELETE)
      has_error = statuses.include? DomainStatus::SERVER_DELETE_PROHIBITED
    end
    errors.add(:domains, I18n.t(:object_status_prohibits_operation)) if has_error
  end

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
    max: -> { Setting.ns_max_count },
  }

  validates :dnskeys, object_count: {
    min: -> { Setting.dnskeys_min_count },
    max: -> { Setting.dnskeys_max_count },
  }

  def self.admin_contacts_validation_rules(for_org:)
    {
      min: -> { for_org ? Setting.admin_contacts_min_count : 0 },
      max: -> { Setting.admin_contacts_max_count }
    }
  end

  def self.tech_contacts_validation_rules(for_org:)
    {
      min: -> { 0 },
      max: -> { Setting.tech_contacts_max_count }
    }
  end

  validates :admin_domain_contacts,
            object_count: admin_contacts_validation_rules(for_org: true),
            if: :require_admin_contacts?

  validates :admin_domain_contacts,
            object_count: admin_contacts_validation_rules(for_org: false),
            unless: :require_admin_contacts?

  validate :validate_admin_contacts_ident_type, on: :create

  validates :tech_domain_contacts,
            object_count: tech_contacts_validation_rules(for_org: true),
            if: :require_tech_contacts?

  validates :tech_domain_contacts,
            object_count: tech_contacts_validation_rules(for_org: false),
            unless: :require_tech_contacts?

  validates :nameservers, uniqueness_multi: {
    attribute: 'hostname',
  }

  validates :dnskeys, uniqueness_multi: {
    attribute: 'public_key',
  }

  validate :validate_nameserver_ips

  validate :statuses_uniqueness

  def security_level_resolver
    resolver = Dnsruby::Resolver.new(nameserver: Dnskey::RESOLVERS)
    resolver.do_validation = true
    resolver.do_caching = false
    resolver.dnssec = true
    resolver
  end

  def dnssec_security_level(stubber: nil)
    Dnsruby::Dnssec.reset
    resolver = security_level_resolver
    Dnsruby::Recursor.clear_caches(resolver)
    if Rails.env.staging?
      clear_dnssec_trusted_anchors_and_keys
    elsif stubber
      Dnsruby::Dnssec.add_trust_anchor(stubber.ds_rr)
    end
    recursor = Dnsruby::Recursor.new(resolver)
    recursor.dnssec = true
    recursor.query(name, 'A', 'IN').security_level
  end

  def clear_dnssec_trusted_anchors_and_keys
    Dnsruby::Dnssec.clear_trust_anchors
    Dnsruby::Dnssec.clear_trusted_keys
    Dnsruby::Dnssec.add_trust_anchor(Dnsruby::RR.create(ENV['trusted_dnskey']))
  end

  def statuses_uniqueness
    return if statuses.uniq == statuses

    errors.add(:statuses, :taken)
  end

  self.ignored_columns = %w[legacy_id legacy_registrar_id legacy_registrant_id]

  def subordinate_nameservers
    nameservers.select { |x| x.hostname.end_with?(name) }
  end

  def delegated_nameservers
    nameservers.reject { |x| x.hostname.end_with?(name) }
  end

  def extension_update_prohibited?
    statuses.include? DomainStatus::SERVER_EXTENSION_UPDATE_PROHIBITED
  end

  def dnskey_update_enabled?
    statuses.include? DomainStatus::SERVER_OBJ_UPDATE_PROHIBITED
  end

  def admin_change_prohibited?
    statuses.include? DomainStatus::SERVER_ADMIN_CHANGE_PROHIBITED
  end

  def tech_change_prohibited?
    statuses.include? DomainStatus::SERVER_TECH_CHANGE_PROHIBITED
  end

  class << self
    def ransackable_associations(*)
      authorizable_ransackable_associations
    end

    def ransackable_attributes(*)
      authorizable_ransackable_attributes
    end

    def nameserver_required?
      Setting.nameserver_required
    end

    def registrant_user_admin_registrant_domains(registrant_user)
      companies = Contact.registrant_user_company_contacts(registrant_user)
      from(
        "(#{registrant_user_administered_domains(registrant_user).to_sql} UNION " \
        "#{registrant_user_company_registrant(companies).to_sql} UNION " \
        "#{registrant_user_domains_company(companies, except_tech: true).to_sql}) AS domains"
      )
    end

    def registrant_user_direct_admin_registrant_domains(registrant_user)
      from(
        "(#{registrant_user_direct_domains_by_registrant(registrant_user).to_sql} UNION " \
        "#{registrant_user_direct_domains_by_contact(registrant_user,
                                                     except_tech: true).to_sql}) AS domains"
      )
    end

    def registrant_user_domains(registrant_user)
      from(
        "(#{registrant_user_domains_by_registrant(registrant_user).to_sql} UNION " \
        "#{registrant_user_indirect_domains(registrant_user).to_sql} UNION " \
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

    def registrant_user_indirect_domains(registrant_user)
      companies = Contact.registrant_user_company_contacts(registrant_user)
      from(
        "(#{registrant_user_company_registrant(companies).to_sql} UNION "\
        "#{registrant_user_domains_company(companies).to_sql}) AS domains"
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

    def registrant_user_direct_domains_by_contact(registrant_user, except_tech: false)
      request = { contact_id: registrant_user.direct_contacts }
      request[:type] = [AdminDomainContact.name] if except_tech
      joins(:domain_contacts).where(domain_contacts: request)
    end

    def registrant_user_company_registrant(companies)
      where(registrant: companies)
    end

    def registrant_user_domains_company(companies, except_tech: false)
      request = { contact: companies }
      request[:type] = [AdminDomainContact.name] if except_tech
      joins(:domain_contacts).where(domain_contacts: request)
    end
  end

  def name=(value)
    value&.strip!
    value&.downcase!
    self[:name] = SimpleIDN.to_unicode(value)
    self[:name_puny] = SimpleIDN.to_ascii(value)
    self[:name_dirty] = value
  end

  # find by internationalized domain name
  # internet domain name => ascii or puny, but db::domains.name is unicode
  def self.find_by_idn(name)
    domain = find_by(name: name)
    if domain.blank? && name.include?('-')
      unicode = SimpleIDN.to_unicode name # we have no index on domains.name_puny
      domain = find_by(name: unicode)
    end
    domain
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
    return false unless renew_blocking_statuses.empty?
    return true unless Setting.days_to_renew_domain_before_expire != 0

    # if you can renew domain at days_to_renew before domain expiration
    return false if (expire_time.to_date - Time.zone.today) + 1 > Setting.days_to_renew_domain_before_expire

    true
  end

  def renew_blocking_statuses
    disallowed = [DomainStatus::DELETE_CANDIDATE, DomainStatus::PENDING_RENEW,
                  DomainStatus::PENDING_TRANSFER, DomainStatus::CLIENT_RENEW_PROHIBITED,
                  DomainStatus::PENDING_UPDATE, DomainStatus::SERVER_RENEW_PROHIBITED,
                  DomainStatus::PENDING_DELETE_CONFIRMATION]

    (statuses & disallowed)
  end

  def notify_registrar(message_key)
    # TODO: To be deleted with DomainDeleteConfirm refactoring
    registrar.notifications.create!(
      text: "#{I18n.t(message_key)}: #{name}",
      attached_obj_id: id,
      attached_obj_type: self.class.to_s
    )
  end

  def preclean_pendings
    # TODO: To be deleted with refactoring
    self.registrant_verification_token = nil
    self.registrant_verification_asked_at = nil
  end

  def clean_pendings!
    # TODO: To be deleted with refactoring
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

    send_time = Time.zone.now + 1.minute
    RegistrantChangeConfirmEmailJob.set(wait_until: send_time).perform_later(id, new_registrant_id)
    RegistrantChangeNoticeEmailJob.set(wait_until: send_time).perform_later(id, new_registrant_id)

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
    return false if statuses.include? DomainStatus::DELETE_CANDIDATE
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

    Domains::DeleteConfirmEmail::SendRequest.run(domain: self)
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

  def pending_update?
    statuses.include?(DomainStatus::PENDING_UPDATE)
  end

  # depricated not used, not valid
  def update_prohibited?
    (statuses & DomainStatus::UPDATE_PROHIBIT_STATES).present?
  end

  # public api
  def delete_prohibited?
    statuses.include?(DomainStatus::FORCE_DELETE)
  end

  def update_unless_locked_by_registrant(update)
    update(admin_store_statuses_history: update) unless locked_by_registrant?
  end

  def update_not_by_locked_statuses(update)
    return unless locked_by_registrant?

    result = update.reject { |status| RegistryLockable::LOCK_STATUSES.include? status }
    update(admin_store_statuses_history: result)
  end

  # special handling for admin changing status
  def admin_status_update(update)
    return unless update

    PaperTrail.request(enabled: false) do
      update_unless_locked_by_registrant(update)
      update_not_by_locked_statuses(update)
    end

    # check for deleted status
    statuses.each do |s|
      next if update.include? s

      case s
      when DomainStatus::PENDING_DELETE
        self.delete_date = nil
      when DomainStatus::SERVER_MANUAL_INZONE # removal causes server hold to set
        self.outzone_at = Time.zone.now if force_delete_scheduled?
      when DomainStatus::EXPIRED # removal causes server hold to set
        self.outzone_at = expire_time + 15.day
      when DomainStatus::SERVER_HOLD # removal causes server hold to set
        self.outzone_at = nil
      end
    end
  end

  def pending_update_prohibited?
    (statuses_was & DomainStatus::UPDATE_PROHIBIT_STATES).present?
  end

  def set_pending_update
    if pending_update_prohibited?
      logger.info "DOMAIN STATUS UPDATE ISSUE ##{id}: PENDING_UPDATE not allowed to set. [#{statuses}]"
      return
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
      return
    end
    statuses << DomainStatus::PENDING_DELETE
  end

  def set_server_hold
    statuses << DomainStatus::SERVER_HOLD
    self.outzone_at = Time.current
  end

  def manage_automatic_statuses
    unless self.class.nameserver_required?
      deactivate if nameservers.reject(&:marked_for_destruction?).empty?
      activate if nameservers.reject(&:marked_for_destruction?).size >= Setting.ns_min_count
    end

    cancel_force_delete if force_delete_scheduled? && will_save_change_to_registrant_id?

    if statuses.empty? && valid?
      statuses << DomainStatus::OK
    elsif (statuses.length > 1) || !valid?
      statuses.delete(DomainStatus::OK)
      statuses.delete(DomainStatus::EXPIRED) unless expired?
    end

    p_d = statuses.include?(DomainStatus::PENDING_DELETE)
    s_h = (statuses & [DomainStatus::SERVER_MANUAL_INZONE, DomainStatus::SERVER_HOLD]).empty?
    statuses << DomainStatus::SERVER_HOLD if p_d && s_h
  end

  def children_log
    log = HashWithIndifferentAccess.new
    log[:admin_contacts] = admin_contact_ids
    log[:tech_contacts] = tech_contact_ids
    log[:nameservers] = nameserver_ids
    log[:dnskeys] = dnskey_ids
    log[:legal_documents] = [legal_document_id]
    log[:registrant] = [registrant_id]
    log
  end

  def update_whois_record
    return if skip_whois_record_update

    UpdateWhoisRecordJob.set(wait: 1.minute).perform_later name, 'domain'
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

  def expired_domain_contact_emails
    (primary_contact_emails +
    ["info@#{name}", "#{prepared_domain_name}@#{name}"]).uniq
  end

  def all_related_emails
    (admin_contacts.emails +  tech_contacts.emails + [registrant.email]).uniq
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
    hash['valid_from'] = hash['created_at'] # API v1 requirement
    hash
  end

  def domain_name
    DNS::DomainName.new(name)
  end

  def contact_emails_verification_failed
    contacts.select(&:email_verification_failed?)&.map(&:email)&.uniq
  end

  def as_csv_row
    [
      name,
      registrant_info[0],
      registrant_info[1],
      registrant_info[2],
      registrant_info[3],
      valid_to.to_formatted_s(:db),
      registrar,
      created_at.to_formatted_s(:db),
      statuses,
      admin_contacts.map { |c| "#{c.name}, #{c.code}, #{ApplicationController.helpers.ident_for(c)}" },
      tech_contacts.map { |c| "#{c.name}, #{c.code}, #{ApplicationController.helpers.ident_for(c)}" },
      nameservers.pluck(:hostname),
      force_delete_date,
      force_delete_data,
    ]
  end

  def as_pdf
    domain_html = ApplicationController.render(template: 'domain/pdf', assigns: { domain: self })
    generator = PDFKit.new(domain_html, { enable_local_file_access: true })
    generator.to_pdf
  end

  def registrant_info
    if registrant
      return [registrant.name, registrant.ident, registrant.ident_country_code,
              registrant.ident_type]
    end

    ver = Version::ContactVersion.where(item_id: registrant_id).last
    contact = Contact.all_versions_for([registrant_id], created_at).first

    contact = ObjectVersionsParser.new(ver).parse if contact.nil? && ver

    [contact.try(:name), contact.try(:ident), contact.try(:ident_country_code),
     contact.try(:ident_type)] || ['Deleted']
  end

  def registrant_ident_info
    return ApplicationController.helpers.ident_for(registrant) if registrant
  end

  def self.csv_header
    [
      'Domain', 'Registrant name', 'Registrant ident', 'Registrant ident country code',
      'Registrant ident type', 'Valid to', 'Registrar', 'Created at',
      'Statuses', 'Admin. contacts', 'Tech. contacts', 'Nameservers', 'Force delete date',
      'Force delete data'
    ]
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
    exists?(['name ILIKE ?', "%.#{zone.origin}"])
  end

  def self.swap_elements(array, indexes)
    indexes.each do |index|
      array[index[0]], array[index[1]] = array[index[1]], array[index[0]]
    end
    array
  end

  def require_admin_contacts?
    return true if registrant.org? && Setting.admin_contacts_required_for_org
    return false unless registrant.priv?
    
    registrant.underage? && Setting.admin_contacts_required_for_minors
  end

  def require_tech_contacts?
    registrant.present? && registrant.org?
  end

  private

  def underage_registrant?
    registrant.underage?
  end

  def validate_admin_contacts_ident_type
    allowed_types = Setting.admin_contacts_allowed_ident_type
    return if allowed_types.blank?

    admin_contacts.each do |contact|
      next if allowed_types[contact.ident_type] == true
      
      errors.add(:admin_contacts, I18n.t(
        'activerecord.errors.models.domain.admin_contact_invalid_ident_type',
        ident_type: contact.ident_type
      ))
    end
  end
end
