class Dispute < ApplicationRecord
  include WhoisStatusPopulate
  validates :domain_name, :password, :starts_at, :expires_at, presence: true
  before_validation :fill_empty_passwords, :set_expiry_date
  validate :validate_domain_name_format
  validate :validate_domain_name_period_uniqueness
  validate :validate_start_date

  before_save :set_expiry_date, :sync_reserved_password, :generate_data
  after_destroy :remove_data

  scope :expired, -> { where('expires_at < ?', Time.zone.today) }
  scope :active, lambda {
    where('starts_at <= ? AND expires_at >= ? AND closed IS NULL', Time.zone.today, Time.zone.today)
  }
  scope :closed, -> { where.not(closed: nil) }

  attr_readonly :domain_name

  def domain
    Domain.find_by(name: domain_name)
  end

  def self.close_by_domain(domain_name)
    dispute = Dispute.active.find_by(domain_name: domain_name)
    return false unless dispute

    dispute.close(initiator: 'Registrant')
  end

  def self.valid_auth?(domain_name, password)
    Dispute.active.find_by(domain_name: domain_name, password: password).present?
  end

  def set_expiry_date
    return if starts_at.blank?

    self.expires_at = starts_at + Setting.dispute_period_in_months.months
  end

  def generate_password
    self.password = SecureRandom.hex
  end

  def generate_data
    return if starts_at > Time.zone.today || expires_at < Time.zone.today

    domain&.mark_as_disputed
    return if domain

    wr = Whois::Record.find_or_initialize_by(name: domain_name)
    wr.json = @json = generate_json(wr, domain_status: 'disputed')
    wr.save
  end

  def close(initiator: 'Unknown')
    return false unless update(closed: Time.zone.now, initiator: initiator)
    return if Dispute.active.where(domain_name: domain_name).any?

    domain&.unmark_as_disputed
    return true if domain

    forward_to_auction_if_possible
  end

  def forward_to_auction_if_possible
    domain = DNS::DomainName.new(domain_name)
    if domain.available? && domain.auctionable?
      domain.sell_at_auction
      return true
    end

    whois_record = Whois::Record.find_by(name: domain_name)
    remove_whois_data(whois_record)
  end

  def remove_whois_data(record)
    return true unless record

    record.json['status'] = record.json['status'].delete_if { |status| status == 'disputed' }
    record.destroy && return if record.json['status'].blank?

    record.save
  end

  def remove_data
    UpdateWhoisRecordJob.enqueue domain_name, 'disputed'
  end

  def fill_empty_passwords
    generate_password if password.blank?
  end

  def sync_reserved_password
    reserved_domain = ReservedDomain.find_by(name: domain_name)
    generate_password if password.blank?

    unless reserved_domain.nil?
      reserved_domain.password = password
      reserved_domain.save!
    end

    generate_data
  end

  private

  def validate_start_date
    return if starts_at.nil?

    errors.add(:starts_at, :future) if starts_at.future?
  end

  def validate_domain_name_format
    return unless domain_name

    zone = domain_name.reverse.rpartition('.').map(&:reverse).reverse.last
    supported_zone = DNS::Zone.origins.include?(zone)

    errors.add(:domain_name, :unsupported_zone) unless supported_zone
  end

  def validate_domain_name_period_uniqueness
    existing_dispute = Dispute.unscoped.where(domain_name: domain_name, closed: nil)
                              .where('expires_at >= ?', starts_at)

    existing_dispute = existing_dispute.where.not(id: id) unless new_record?

    return unless existing_dispute.any?

    errors.add(:starts_at, 'Dispute already exists for this domain at given timeframe')
  end
end
