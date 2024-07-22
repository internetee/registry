class ReservedDomain < ApplicationRecord
  has_secure_token :access_token

  before_create :set_token_created_at

  include Versions # version/reserved_domain_version.rb
  include WhoisStatusPopulate
  before_save :fill_empty_passwords
  before_save :generate_data
  before_save :sync_dispute_password
  after_destroy :remove_data

  validates :name, domain_name: true, uniqueness: true

  alias_attribute :registration_code, :password

  self.ignored_columns = %w[legacy_id]

  class << self
    def ransackable_associations(*)
      authorizable_ransackable_associations
    end

    def ransackable_attributes(*)
      authorizable_ransackable_attributes
    end

    def pw_for(domain_name)
      name_in_ascii = SimpleIDN.to_ascii(domain_name)
      by_domain(domain_name).first.try(:password) || by_domain(name_in_ascii).first.try(:password)
    end

    def by_domain(name)
      where(name: name)
    end

    def new_password_for(name)
      record = by_domain(name).first
      return unless record

      record.regenerate_password
      record.save
    end
  end

  def name=(val)
    super SimpleIDN.to_unicode(val)
  end

  def fill_empty_passwords
    regenerate_password if password.blank?
  end

  def regenerate_password
    self.password = SecureRandom.hex
  end

  def sync_dispute_password
    dispute = Dispute.active.find_by(domain_name: name)
    self.password = dispute.password if dispute.present?
  end

  def generate_data
    return if Domain.where(name: name).any?

    wr = Whois::Record.find_or_initialize_by(name: name)
    wr.json = @json = generate_json(wr, domain_status: 'Reserved') # we need @json to bind to class
    wr.save
  end

  alias_method :update_whois_record, :generate_data

  def remove_data
    UpdateWhoisRecordJob.perform_later name, 'reserved'
  end

  def token_expired?
    token_created_at.nil? || token_created_at < 30.days.ago
  end

  def refresh_token
    regenerate_access_token
    update(token_created_at: Time.current)
  end

  private

  def set_token_created_at
    self.token_created_at = Time.current
  end
end
