require 'open3'

class ApiUser < User
  include EppErrors
  devise :database_authenticatable, :trackable, :timeoutable,
         authentication_keys: [:username]

  def epp_code_map
    {
      '2306' => [ # Parameter policy error
        %i[plain_text_password blank],
        %i[email blank],
        %i[base verification_error],
        %i[base not_pending_verification],
        %i[identity_code taken],
        %i[subject taken],
        %i[base missing_subject]
      ]
    }
  end

  def self.min_password_length # Must precede .validates
    6
  end

  # TODO: should have max request limit per day?
  belongs_to :registrar
  has_many :certificates

  VALID_EMAIL_REGEX = /\A([\w+\-]\.?)+@[a-z\d\-]+(\.[a-z]+)*\.[a-z]+\z/i.freeze

  validates :username, :plain_text_password, :registrar, :roles, presence: true
  validates :plain_text_password, length: { minimum: min_password_length }
  validates :username, uniqueness: true
  validates :email, format: { with: VALID_EMAIL_REGEX, allow_blank: true }
  validates :identity_code, uniqueness: { scope: :registrar_id }, if: -> { identity_code.present? }
  validates :subject, uniqueness: { scope: :registrar_id }, if: -> { subject.present? }
  before_validation :clear_verification_status_on_subject_change, if: :subject_changed_from_existing?
  after_commit :notify_registrar_subject_changed, on: :update

  scope :eligible_for_sign_in, lambda {
    where(active: true).where.not(verified_at: nil)
  }

  def identity_verified?
    verified_at.present?
  end

  def eligible_for_sign_in?
    active? && identity_verified?
  end

  def verification_pending?
    verification_pending_at.present?
  end

  delegate :code, :name, to: :registrar, prefix: true
  delegate :legaldoc_mandatory?, to: :registrar

  alias_attribute :login, :username

  SUPER = 'super'.freeze
  EPP = 'epp'.freeze
  BILLING = 'billing'.freeze

  ROLES = %w[super epp billing].freeze # should not match to admin roles

  scope :non_super, -> { where.not('roles @> ARRAY[?]::varchar[]', ['super']) }

  def ability
    @ability ||= Ability.new(self)
  end
  delegate :can?, :cannot?, to: :ability

  after_initialize :set_defaults
  def set_defaults
    return unless new_record?

    self.active = true unless saved_change_to_active?
  end

  def to_s
    username
  end

  def name
    username
  end

  def unread_notifications
    registrar.notifications.unread
  end

  def pki_ok?(crt, com, api: true)
    return false if crt.blank? || com.blank?

    origin = api ? certificates.api : certificates.registrar
    cert = machine_readable_certificate(crt)
    md5 = OpenSSL::Digest::MD5.new(cert.to_der).to_s

    origin.exists?(md5: md5, common_name: com, revoked: false)
  end

  def linked_users
    return self.class.none if subject.blank?

    self.class.where(subject: subject, active: true)
        .where.not(verified_at: nil)
        .where.not(id: id)
        .includes(:registrar)
  end

  def api_users
    self.class.where(registrar_id: registrar_id)
  end

  def linked_with?(another_api_user)
    return false if another_api_user.blank? || subject.blank?

    another_api_user.subject == subject
  end

  def as_csv_row
    [
      username,
      plain_text_password,
      identity_code,
      roles.join(', '),
      active,
      created_at, updated_at
    ]
  end

  def self.csv_header
    ['Username', 'Password', 'Identity Code', 'Role', 'Active',
     'Created', 'Updated']
  end

  def self.ransackable_associations(*)
    authorizable_ransackable_associations
  end

  def self.ransackable_attributes(*)
    authorizable_ransackable_attributes
  end

  private

  def subject_changed_from_existing?
    return false unless persisted?
    return false unless will_save_change_to_subject?
    return false if subject_in_database.to_s.blank?

    subject.to_s != subject_in_database.to_s
  end

  def clear_verification_status_on_subject_change
    @subject_change_notification_data = {
      old_subject: subject_in_database.to_s,
      new_subject: subject.to_s
    }

    self.ident_request_sent_at = nil
    self.verified_at = nil
    self.verification_id = nil
    self.verification_pending_at = nil
    self.verification_snapshot = {}
  end

  def notify_registrar_subject_changed
    data = @subject_change_notification_data
    @subject_change_notification_data = nil
    return if data.blank?

    email = registrar&.email
    return if email.blank?

    RegistrarMailer.api_user_subject_changed(
      email: email,
      api_user: self,
      old_subject: data[:old_subject],
      new_subject: data[:new_subject]
    ).deliver_now
  end

  def machine_readable_certificate(cert)
    Rails.logger.debug "[machine_readable_certificate] Original cert: #{cert}"

    # Handle URL-encoded certificates (in case HAProxy url_dec didn't work properly)
    # Only decode actual URL-encoded characters (%XX), preserving + signs
    if cert.include?('%')
      # Custom decoding that only handles %XX patterns, not + signs
      cert = cert.gsub(/%[0-9A-Fa-f]{2}/) { |match| [match[1..2]].pack('H*') }
      Rails.logger.debug "[machine_readable_certificate] URL-decoded cert: #{cert}"
    end

    # Handle certificates that might have spaces instead of newlines
    if cert.include?(' ') && !cert.include?("\n")
      cert = cert.split(' ').join("\n")
      Rails.logger.debug "[machine_readable_certificate] Fixed newlines: #{cert}"
    end

    # Fix common certificate header/footer formatting issues
    cert = cert.gsub(/-----BEGIN\s*CERTIFICATE\s*-----/, '-----BEGIN CERTIFICATE-----')
    cert = cert.gsub(/-----END\s*CERTIFICATE\s*-----/, '-----END CERTIFICATE-----')

    # Ensure proper newlines around headers
    cert = cert.gsub(/([^-])-----BEGIN CERTIFICATE-----/, "\\1\n-----BEGIN CERTIFICATE-----")
    cert = cert.gsub(/-----END CERTIFICATE-----([^-])/, "-----END CERTIFICATE-----\n\\1")

    # Remove any extra whitespace and ensure proper formatting
    cert = cert.strip

    Rails.logger.debug "[machine_readable_certificate] Final formatted cert: #{cert}"

    # Validate that we have a proper certificate structure
    unless cert.match?(/-----BEGIN CERTIFICATE-----\n.*\n-----END CERTIFICATE-----/m)
      Rails.logger.error '[machine_readable_certificate] Invalid certificate format after parsing'
      raise ArgumentError, 'Invalid certificate format'
    end

    OpenSSL::X509::Certificate.new(cert)
  rescue OpenSSL::X509::CertificateError => e
    Rails.logger.error "[machine_readable_certificate] Failed to parse certificate: #{e.message}"
    Rails.logger.error "[machine_readable_certificate] Certificate content: #{cert}"
    raise e
  end
end
