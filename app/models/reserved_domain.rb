class ReservedDomain < ApplicationRecord
  include Versions # version/reserved_domain_version.rb
  before_save :fill_empty_passwords
  before_save :generate_data
  before_save :sync_dispute_password
  after_destroy :remove_data

  validates :name, domain_name: true, uniqueness: true

  alias_attribute :registration_code, :password

  self.ignored_columns = %w[legacy_id]

  class << self
    def pw_for(domain_name)
      name_in_ascii = SimpleIDN.to_ascii(domain_name)
      by_domain(domain_name).first.try(:password) || by_domain(name_in_ascii).first.try(:password)
    end

    def by_domain name
      where(name: name)
    end

    def new_password_for name
      record = by_domain(name).first
      return unless record

      record.regenerate_password
      record.save
    end
  end

  def name= val
    super SimpleIDN.to_unicode(val)
  end

  def fill_empty_passwords
    regenerate_password if self.password.blank?
  end

  def regenerate_password
    self.password = SecureRandom.hex
  end

  def sync_dispute_password
    dispute = Dispute.active.find_by(domain_name: domain_name)
    self.password = dispute.password if dispute.present?
  end

  def generate_data
    return if Domain.where(name: name).any?

    wr = Whois::Record.find_or_initialize_by(name: name)
    wr.json = @json = generate_json # we need @json to bind to class
    wr.save
  end

  alias_method :update_whois_record, :generate_data

  def generate_json
    h = HashWithIndifferentAccess.new
    h[:name] = self.name
    h[:status] = ['Reserved']
    h
  end

  def remove_data
    UpdateWhoisRecordJob.enqueue name, 'reserved'
  end
end
