class ReservedDomain < ApplicationRecord
  include Versions # version/reserved_domain_version.rb
  include WhoisStatusPopulate
  before_save :fill_empty_passwords
  before_save :generate_data
  before_save :sync_dispute_password
  after_destroy_commit :remove_data

  validates :name, domain_name: true, uniqueness: true

  alias_attribute :registration_code, :password

  scope :expired, ->(at = Time.current) { where('expire_at < ?', at) }

  ransacker :expire_date do
    Arel.sql('DATE(expire_at)')
  end

  self.ignored_columns = %w[legacy_id]

  MAX_DOMAIN_NAME_PER_REQUEST = 20

  FREE_RESERVATION_EXPIRY = 7.days
  PAID_RESERVATION_EXPIRY = 1.year

  EXPIRED_RELEASE_REASON = 'Expired reservation deadline reached'.freeze
  DAILY_CLEANUP_PROCESS = 'Automated daily cleanup job'.freeze
  AVAILABILITY_CHECK_PROCESS = 'Business registry availability check'.freeze

  AUDIT_SOURCES = %w[
    business_registry eis_billing admin registrar dispute
    expiry_job availability_check console rake unknown
  ].freeze

  AUDIT_REASONS = %w[
    free_reservation paid_reservation admin_created admin_updated admin_deleted
    released_to_auction domain_registered dispute_password_sync reservation_expired
  ].freeze

  AUDIT_SOURCE_BY_PROCESS = {
    DAILY_CLEANUP_PROCESS => 'expiry_job',
    AVAILABILITY_CHECK_PROCESS => 'availability_check'
  }.freeze

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

    def wrap_reserved_domains_to_struct(reserved_domains, success, user_unique_id = nil, errors = nil)
      Struct.new(:reserved_domains, :success, :user_unique_id, :errors).new(reserved_domains, success, user_unique_id, errors)
    end

    # Reservation lasts full calendar days: the activation day is not counted,
    # the period starts at 00:00 of the next day and ends at 23:59:59 of its last day.
    def expire_at_for(period, from: Time.zone.now)
      (from + period).end_of_day.change(usec: 0)
    end

    def reserve_domains_without_payment(domain_names)
      if domain_names.count > MAX_DOMAIN_NAME_PER_REQUEST
        return wrap_reserved_domains_to_struct(domain_names, false, nil, "The maximum number of domain names per request is #{MAX_DOMAIN_NAME_PER_REQUEST}")
      end

      available_domains = BusinessRegistry::DomainAvailabilityCheckerService.filter_available(domain_names)

      reserved_domains = []
      Audit.set(reason: 'free_reservation', reason_note: nil, registrar_id: nil) do
        available_domains.each do |domain_name|
          reserved_domain = ReservedDomain.new(
            name: domain_name,
            expire_at: expire_at_for(FREE_RESERVATION_EXPIRY)
          )
          reserved_domain.regenerate_password
          reserved_domain.save
          reserved_domains << reserved_domain
        end
      end

      return wrap_reserved_domains_to_struct(reserved_domains, false, nil, "No available domains") if reserved_domains.empty?

      unique_id = FreeDomainReservationHolder.create!(domain_names: available_domains).user_unique_id
      wrap_reserved_domains_to_struct(reserved_domains, true, unique_id)
    end

    def release_expired(at: Time.current)
      released = 0
      failed = 0

      expired(at).find_each do |reserved_domain|
        released += 1 if reserved_domain.release_if_expired(process: DAILY_CLEANUP_PROCESS, at: at)
      rescue ActiveRecord::RecordNotFound
        next
      rescue StandardError => e
        failed += 1
        message = "Failed to release reserved domain #{reserved_domain.id} (#{reserved_domain.name}): #{e.class} - #{e.message}"
        ToStdout.msg message
        Rails.logger.error message
      end

      ToStdout.msg "Released #{released} expired reserved domains (failed: #{failed})"
      released
    end
  end

  def expired?(at = Time.current)
    expire_at.present? && expire_at < at
  end

  # with_lock reloads the row with FOR UPDATE, so a reservation extended
  # after this record was loaded is not released.
  def release_if_expired(process:, at: Time.current)
    released = false

    with_lock do
      if expired?(at)
        audit = release_audit_message(process)

        PaperTrail.request(whodunnit: audit) do
          Audit.set(source: AUDIT_SOURCE_BY_PROCESS.fetch(process, 'unknown'),
                    reason: 'reservation_expired', reason_note: nil, registrar_id: nil) do
            update!(updator_str: audit)
            destroy!
          end
        end

        released = true
      end
    end

    released
  end

  def destroy_if_expired
    release_if_expired(process: AVAILABILITY_CHECK_PROCESS)
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

  def audit_source
    Audit.source || audit_source_from_whodunnit
  end

  def audit_reason
    Audit.reason
  end

  def audit_reason_note
    Audit.reason_note
  end

  def audit_registrar_id
    Audit.registrar_id
  end

  private

  def audit_source_from_whodunnit
    case ::PaperTrail.request.whodunnit.to_s
    when /\A\d+-AdminUser:/ then 'admin'
    when /\A\d+-ApiUser:/ then 'registrar'
    when /\Aconsole-/ then 'console'
    when /\Arake-/ then 'rake'
    else 'unknown'
    end
  end

  def release_audit_message(process)
    "#{process} - #{EXPIRED_RELEASE_REASON} - #{Time.current.iso8601}"
  end
end
