# rubocop: disable Metrics/ClassLength
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

  before_save :manage_automatic_statuses

  before_save :touch_always_version
  def touch_always_version
    self.updated_at = Time.zone.now
  end
  after_save :update_whois_record

  after_initialize -> { self.statuses = [] if statuses.nil? }

  validates :name_dirty, domain_name: true, uniqueness: true
  validates :puny_label, length: { maximum: 63 }
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

    def start_expire_period
      STDOUT << "#{Time.zone.now.utc} - Expiring domains\n" unless Rails.env.test?

      d = Domain.where('valid_to <= ?', Time.zone.now)
      d.each do |x|
        next unless x.expirable?
        x.statuses << DomainStatus::EXPIRED
        # TODO: This should be managed by automatic_statuses
        x.statuses.delete(DomainStatus::OK)
        x.save(validate: false)
      end

      STDOUT << "#{Time.zone.now.utc} - Successfully expired #{d.count} domains\n" unless Rails.env.test?
    end

    def start_redemption_grace_period
      STDOUT << "#{Time.zone.now.utc} - Setting server_hold to domains\n" unless Rails.env.test?

      d = Domain.where('outzone_at <= ?', Time.zone.now)
      d.each do |x|
        next unless x.server_holdable?
        x.statuses << DomainStatus::SERVER_HOLD
        # TODO: This should be managed by automatic_statuses
        x.statuses.delete(DomainStatus::OK)
        x.save
      end

      STDOUT << "#{Time.zone.now.utc} - Successfully set server_hold to #{d.count} domains\n" unless Rails.env.test?
    end

    def start_delete_period
      STDOUT << "#{Time.zone.now.utc} - Setting delete_candidate to domains\n" unless Rails.env.test?

      d = Domain.where('delete_at <= ?', Time.zone.now)
      d.each do |x|
        x.domain_statuses.create(value: DomainStatus::DELETE_CANDIDATE) if x.delete_candidateable?
        # TODO: This should be managed by automatic_statuses
        x.domain_statuses.where(value: DomainStatus::OK).destroy_all
      end

      return if Rails.env.test?
      STDOUT << "#{Time.zone.now.utc} - Successfully set delete_candidate to #{d.count} domains\n"
    end

    def destroy_delete_candidates
      STDOUT << "#{Time.zone.now.utc} - Destroying domains\n" unless Rails.env.test?

      c = 0
      DomainStatus.where(value: DomainStatus::DELETE_CANDIDATE).each do |x|
        x.domain.destroy
        c += 1
      end

      Domain.where('force_delete_at <= ?', Time.zone.now).each do |x|
        x.destroy
        c += 1
      end

      STDOUT << "#{Time.zone.now.utc} - Successfully destroyed #{c} domains\n" unless Rails.env.test?
    end
  end

  def name=(value)
    value.strip!
    value.downcase!
    self[:name] = SimpleIDN.to_unicode(value)
    self[:name_puny] = SimpleIDN.to_ascii(value)
    self[:name_dirty] = value
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

  def pending_transfer
    domain_transfers.find_by(status: DomainTransfer::PENDING)
  end

  def can_be_deleted?
    (domain_statuses.pluck(:value) & %W(
      #{DomainStatus::SERVER_DELETE_PROHIBITED}
    )).empty?
  end

  def expirable?
    return false if valid_to > Time.zone.now
    domain_statuses.where(value: DomainStatus::EXPIRED).empty?
  end

  def server_holdable?
    return false if outzone_at > Time.zone.now
    return false if domain_statuses.where(value: DomainStatus::SERVER_HOLD).any?
    return false if domain_statuses.where(value: DomainStatus::SERVER_MANUAL_INZONE).any?
    true
  end

  def delete_candidateable?
    return false if delete_at > Time.zone.now
    return false if domain_statuses.where(value: DomainStatus::DELETE_CANDIDATE).any?
    return false if domain_statuses.where(value: DomainStatus::SERVER_DELETE_PROHIBITED).any?
    true
  end

  def renewable?
    if Setting.days_to_renew_domain_before_expire != 0
      if ((valid_to - Time.zone.now.beginning_of_day).to_i / 1.day) + 1 > Setting.days_to_renew_domain_before_expire
        return false
      end
    end

    return false if domain_statuses.where(value: DomainStatus::DELETE_CANDIDATE).any?

    true
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

  def force_deletable?
    domain_statuses.where(value: DomainStatus::FORCE_DELETE).empty?
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
    self.valid_from = Time.zone.now
    self.valid_to = valid_from + self.class.convert_period_to_time(period, period_unit)
    self.outzone_at = valid_to + Setting.expire_warning_period.days
    self.delete_at = outzone_at + Setting.redemption_grace_period.days
  end

  def set_force_delete
    domain_statuses.where(value: DomainStatus::FORCE_DELETE).first_or_create
    domain_statuses.where(value: DomainStatus::SERVER_RENEW_PROHIBITED).first_or_create
    domain_statuses.where(value: DomainStatus::SERVER_TRANSFER_PROHIBITED).first_or_create
    domain_statuses.where(value: DomainStatus::SERVER_UPDATE_PROHIBITED).first_or_create
    domain_statuses.where(value: DomainStatus::SERVER_MANUAL_INZONE).first_or_create
    domain_statuses.where(value: DomainStatus::PENDING_DELETE).first_or_create
    domain_statuses.where(value: DomainStatus::CLIENT_DELETE_PROHIBITED).destroy_all
    domain_statuses.where(value: DomainStatus::SERVER_DELETE_PROHIBITED).destroy_all
    domain_statuses.reload
    self.force_delete_at = Time.zone.now + Setting.redemption_grace_period.days unless force_delete_at
    save(validate: false)
  end

  def unset_force_delete
    domain_statuses.where(value: DomainStatus::FORCE_DELETE).destroy_all
    domain_statuses.where(value: DomainStatus::SERVER_RENEW_PROHIBITED).destroy_all
    domain_statuses.where(value: DomainStatus::SERVER_TRANSFER_PROHIBITED).destroy_all
    domain_statuses.where(value: DomainStatus::SERVER_UPDATE_PROHIBITED).destroy_all
    domain_statuses.where(value: DomainStatus::SERVER_MANUAL_INZONE).destroy_all
    domain_statuses.where(value: DomainStatus::PENDING_DELETE).destroy_all
    domain_statuses.reload
    self.force_delete_at = nil
    save(validate: false)
  end

  def manage_automatic_statuses
    # domain_statuses.create(value: DomainStatus::DELETE_CANDIDATE) if delete_candidateable?
    if statuses.empty? && valid?
      statuses << DomainStatus::OK
    elsif statuses.length > 1 || !valid?
      statuses.delete(DomainStatus::OK)
    end

    # otherwise domain_statuses are in old state for domain object
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
# rubocop: enable Metrics/ClassLength
