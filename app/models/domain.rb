class Domain < ActiveRecord::Base
  # TODO whois requests ip whitelist for full info for own domains and partial info for other domains
  # TODO most inputs should be trimmed before validatation, probably some global logic?
  belongs_to :registrar
  belongs_to :owner_contact, class_name: 'Contact'

  has_many :domain_contacts, dependent: :delete_all, autosave: true

  has_many :tech_contacts, -> do
    where(domain_contacts: { contact_type: DomainContact::TECH })
  end, through: :domain_contacts, source: :contact

  has_many :admin_contacts, -> do
    where(domain_contacts: { contact_type: DomainContact::ADMIN })
  end, through: :domain_contacts, source: :contact

  has_many :nameservers, dependent: :delete_all, autosave: true

  has_many :domain_statuses, dependent: :delete_all

  has_many :domain_transfers, dependent: :delete_all

  delegate :code, to: :owner_contact, prefix: true
  delegate :email, to: :owner_contact, prefix: true
  delegate :ident, to: :owner_contact, prefix: true
  delegate :phone, to: :owner_contact, prefix: true
  delegate :name, to: :registrar, prefix: true

  before_create :generate_auth_info
  before_create :set_validity_dates
  after_create :attach_default_contacts

  validates :name_dirty, domain_name: true, uniqueness: true
  validates :period, numericality: { only_integer: true }
  validates :owner_contact, presence: true

  validate :validate_period

  attr_accessor :adding_admin_contact
  validate :validate_admin_contacts_max_count, if: :adding_admin_contact

  attr_accessor :deleting_admin_contact
  validate :validate_admin_contacts_min_count, if: :deleting_admin_contact

  attr_accessor :adding_nameserver
  validate :validate_nameserver_max_count, if: :adding_nameserver

  attr_accessor :deleting_nameserver
  validate :validate_nameserver_min_count, if: :deleting_nameserver

  attr_accessor :adding_tech_contact
  validate :validate_tech_contacts_max_count, if: :adding_tech_contact

  attr_accessor :deleting_tech_contact
  # validate :validate_tech_contacts_min_count, if: :deleting_tech_contact

  def name=(value)
    value.strip!
    write_attribute(:name, SimpleIDN.to_unicode(value))
    write_attribute(:name_puny, SimpleIDN.to_ascii(value))
    write_attribute(:name_dirty, value)
  end

  def pending_transfer
    domain_transfers.find_by(status: DomainTransfer::PENDING)
  end

  def can_be_deleted?
    (domain_statuses.pluck(:value) & %W(
      #{DomainStatus::CLIENT_DELETE_PROHIBITED}
      #{DomainStatus::SERVER_DELETE_PROHIBITED}
    )).empty?
  end

  ### VALIDATIONS ###
  def validate_admin_contacts_max_count
    return if admin_contacts_count < 4
    errors.add(:admin_contacts, :out_of_range)
  end

  def validate_admin_contacts_min_count
    return if admin_contacts_count > 2
    errors.add(:admin_contacts, :out_of_range)
  end

  def validate_nameserver_max_count
    sg = SettingGroup.domain_validation
    max = sg.setting(:ns_max_count).value.to_i
    return if nameservers.length <= max
    errors.add(:nameservers, :less_than_or_equal_to, { count: max })
  end

  def validate_nameserver_min_count
    sg = SettingGroup.domain_validation
    min = sg.setting(:ns_min_count).value.to_i
    return if nameservers.reject(&:marked_for_destruction?).length >= min
    errors.add(:nameservers, :greater_than_or_equal_to, { count: min })
  end

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

  def all_dependencies_valid?
    validate_nameservers_count
    validate_admin_contacts_count

    errors.empty?
  end

  ## SHARED

  def to_s
    name
  end

  def generate_auth_info
    begin
      self.auth_info = SecureRandom.hex
    end while self.class.exists?(auth_info: auth_info)
  end

  def attach_default_contacts
    tech_contacts << owner_contact if tech_contacts_count.zero?
    admin_contacts << owner_contact if admin_contacts_count.zero? && owner_contact.citizen?
  end

  def set_validity_dates
    self.registered_at = Time.zone.now
    self.valid_from = Date.today
    self.valid_to = valid_from + self.class.convert_period_to_time(period, period_unit)
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
  end
end
