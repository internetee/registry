# frozen_string_literal: true

class Dispute < ApplicationRecord
  validates :domain_name, :password, :starts_at, :expires_at, presence: true
  validates_uniqueness_of :domain_name, case_sensitive: true
  before_validation :fill_empty_passwords
  before_validation :set_expiry_date
  validate :validate_domain_name

  with_options on: :admin do
    validate :validate_start_date
  end
  before_save :set_expiry_date
  before_save :sync_reserved_password
  after_destroy :remove_data

  scope :expired, -> { where('expires_at < ?', Time.zone.today) }
  scope :active, -> { where('expires_at > ? AND closed = 0', Time.zone.today) }
  scope :closed, -> { where(closed: true) }

  alias_attribute :name, :domain_name

  def set_expiry_date
    return if starts_at.blank?

    self.expires_at = starts_at + Setting.dispute_period_in_months.months
  end

  def generate_password
    self.password = SecureRandom.hex
  end

  def generate_data
    return if Domain.where(name: domain_name).any?

    wr = Whois::Record.find_or_initialize_by(name: domain_name)
    wr.json = @json = generate_json # we need @json to bind to class
    wr.save
  end

  def close
    self.closed = true
    save!
  end

  def generate_json
    h = HashWithIndifferentAccess.new
    h[:name] = domain_name
    h[:status] = ['Disputed']
    h
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

    errors.add(:starts_at, :past) if starts_at.past?
  end

  def validate_domain_name
    return unless domain_name

    zone = domain_name.split('.').last
    supported_zone = DNS::Zone.origins.include?(zone)

    errors.add(:domain_name, :unsupported_zone) unless supported_zone
  end
end
