class Domain < ActiveRecord::Base
  include Versions # version/domain_version.rb
  has_paper_trail class_name: "DomainVersion", meta: { children: :children_log }

  # TODO: whois requests ip whitelist for full info for own domains and partial info for other domains
  # TODO: most inputs should be trimmed before validatation, probably some global logic?
  paginates_per 10 # just for showoff

  belongs_to :registrar
  belongs_to :registrant

  has_many :domain_contacts, dependent: :destroy
  has_many :admin_domain_contacts
  accepts_nested_attributes_for :admin_domain_contacts, allow_destroy: true
  has_many :tech_domain_contacts
  accepts_nested_attributes_for :tech_domain_contacts, allow_destroy: true

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
  has_one :whois_record, dependent: :destroy

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

  before_create :generate_auth_info
  before_create :set_validity_dates
  before_update :manage_statuses
  def manage_statuses
    return unless registrant_id_changed?
    pending_update! if registrant_verification_asked?
    true
  end

  before_save :touch_always_version
  def touch_always_version
    self.updated_at = Time.zone.now
  end
  after_save :manage_automatic_statuses
  after_save :update_whois_record

  validates :name_dirty, domain_name: true, uniqueness: true
  validates :period, numericality: { only_integer: true }
  validates :registrant, :registrar, presence: true

  validate :validate_period

  validates :nameservers, object_count: {
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

  attr_accessor :registrant_typeahead, :update_me, :deliver_emails, 
    :epp_pending_update, :epp_pending_delete

  def subordinate_nameservers
    nameservers.select { |x| x.hostname.end_with?(name) }
  end

  def delegated_nameservers
    nameservers.select { |x| !x.hostname.end_with?(name) }
  end

  class << self
    def convert_period_to_time(period, unit)
      return period.to_i.days   if unit == 'd'
      return period.to_i.months if unit == 'm'
      return period.to_i.years  if unit == 'y'
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
  end

  def name=(value)
    value.strip!
    value.downcase!
    self[:name] = SimpleIDN.to_unicode(value)
    self[:name_puny] = SimpleIDN.to_ascii(value)
    self[:name_dirty] = value
  end

  def registrant_typeahead
    @registrant_typeahead || registrant.try(:name) || nil
  end

  def pending_transfer
    domain_transfers.find_by(status: DomainTransfer::PENDING)
  end

  def can_be_deleted?
    (domain_statuses.pluck(:value) & %W(
      #{DomainStatus::SERVER_DELETE_PROHIBITED}
    )).empty?
  end

  def pending_update?
    (domain_statuses.pluck(:value) & %W(
      #{DomainStatus::PENDING_UPDATE}
    )).present?
  end

  def pending_update!
    return true if pending_update?
    self.epp_pending_update = true # for epp

    return true unless registrant_verification_asked?
    pending_json_cache = all_changes
    token = registrant_verification_token
    asked_at = registrant_verification_asked_at

    DomainMailer.registrant_pending_updated(self).deliver_now

    reload # revert back to original

    self.pending_json = pending_json_cache
    self.registrant_verification_token = token
    self.registrant_verification_asked_at = asked_at
    domain_statuses.create(value: DomainStatus::PENDING_UPDATE)
  end

  def registrant_update_confirmable?(token)
    return false unless pending_update?
    return false if registrant_verification_token.blank?
    return false if registrant_verification_asked_at.blank?
    return false if token.blank?
    return false if registrant_verification_token != token
    true
  end

  def registrant_delete_confirmable?(token)
    return false unless pending_delete?
    return false if registrant_verification_token.blank?
    return false if registrant_verification_asked_at.blank?
    return false if token.blank?
    return false if registrant_verification_token != token
    true
  end

  def registrant_verification_asked?
    registrant_verification_asked_at.present? && registrant_verification_token.present?
  end

  def registrant_verification_asked!
    self.registrant_verification_asked_at = Time.zone.now
    self.registrant_verification_token = SecureRandom.hex(42)
  end

  def pending_delete?
    (domain_statuses.pluck(:value) & %W(
      #{DomainStatus::PENDING_DELETE}
    )).present?
  end

  def pending_delete!
    return true if pending_delete?
    self.epp_pending_delete = true # for epp

    return true unless registrant_verification_asked?
    domain_statuses.create(value: DomainStatus::PENDING_DELETE)
    DomainMailer.pending_deleted(self).deliver_now
  end

  ### VALIDATIONS ###

  def validate_nameserver_ips
    nameservers.each do |ns|
      next unless ns.hostname.end_with?(name)
      next if ns.ipv4.present?
      errors.add(:nameservers, :invalid) if errors[:nameservers].blank?
      ns.errors.add(:ipv4, :blank)
    end
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

  # used for highlighting form tabs
  def parent_valid?
    assoc_errors = errors.keys.select { |x| x.match(/\./) }
    (errors.keys - assoc_errors).empty?
  end

  def statuses_tab_valid?
    !errors.keys.any? { |x| x.match(/domain_statuses/) }
  end

  ## SHARED

  def name_in_wire_format
    res = ''
    parts = name.split('.')
    parts.each do |x|
      res += sprintf('%02X', x.length) # length of label in hex
      res += x.each_byte.map { |b| sprintf('%02X', b) }.join # label
    end

    res += '00'

    res
  end

  def to_s
    name
  end

  def pending_registrant_name
    return '' if pending_json.blank?
    return '' if pending_json['domain'].blank?
    return '' if pending_json['domain']['registrant_id'].blank?
    registrant = Registrant.find_by(id: pending_json['domain']['registrant_id'].last)
    registrant.try(:name)
  end

  # rubocop:disable Lint/Loop
  def generate_auth_info
    begin
      self.auth_info = SecureRandom.hex
    end while self.class.exists?(auth_info: auth_info)
  end
  # rubocop:enable Lint/Loop

  def set_validity_dates
    self.registered_at = Time.zone.now
    self.valid_from = Time.zone.now.to_date
    self.valid_to = valid_from + self.class.convert_period_to_time(period, period_unit)
  end

  def manage_automatic_statuses
    if domain_statuses.empty? && valid?
      domain_statuses.create(value: DomainStatus::OK)
    elsif domain_statuses.length > 1 || !valid?
      domain_statuses.find_by(value: DomainStatus::OK).try(:destroy)
    end

    # otherwise domain_statuses are in old state for domain object
    domain_statuses.reload
  end

  def children_log
    log = HashWithIndifferentAccess.new
    log[:admin_contacts] = admin_contacts.map(&:attributes)
    log[:tech_contacts]  = tech_contacts.map(&:attributes)
    log[:nameservers]    = nameservers.map(&:attributes)
    log[:registrant]     = [registrant.try(:attributes)]
    log[:domain_statuses] = domain_statuses.map(&:attributes)
    log
  end

  def all_changes
    all_changes = HashWithIndifferentAccess.new
    all_changes[:domain] = changes
    all_changes[:admin_contacts]  = admin_contacts.map(&:changes)
    all_changes[:tech_contacts]   = tech_contacts.map(&:changes)
    all_changes[:nameservers]     = nameservers.map(&:changes)
    all_changes[:registrant]      = registrant.try(:changes)
    all_changes[:domain_statuses] = domain_statuses.map(&:changes)
    all_changes
  end

  def update_whois_record
    whois_record.blank? ? create_whois_record : whois_record.save
  end
end
