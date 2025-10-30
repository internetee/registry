require 'open3'

class ApiUser < User
  include EppErrors
  devise :database_authenticatable, :trackable, :timeoutable,
         authentication_keys: [:username]

  def epp_code_map
    {
      '2306' => [ # Parameter policy error
        %i[plain_text_password blank]
      ]
    }
  end

  def self.min_password_length # Must precede .validates
    6
  end

  # TODO: should have max request limit per day?
  belongs_to :registrar
  has_many :certificates

  validates :username, :plain_text_password, :registrar, :roles, presence: true
  validates :plain_text_password, length: { minimum: min_password_length }
  validates :username, uniqueness: true
  validates :identity_code, uniqueness: { scope: :registrar_id }, if: -> { identity_code.present? }

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

  def accredited?
    !accreditation_date.nil?
  end

  def accreditation_expired?
    return false if accreditation_expire_date.nil?

    accreditation_expire_date < Time.zone.now
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
    self.class.where(identity_code: identity_code, active: true)
        .where("identity_code IS NOT NULL AND identity_code != ''")
        .where.not(id: id)
        .includes(:registrar)
  end

  def api_users
    self.class.where(registrar_id: registrar_id)
  end

  def linked_with?(another_api_user)
    another_api_user.identity_code == identity_code
  end

  def as_csv_row
    [
      username,
      plain_text_password,
      identity_code,
      roles.join(', '),
      active,
      accredited?,
      accreditation_expire_date,
      created_at, updated_at
    ]
  end

  def self.csv_header
    ['Username', 'Password', 'Identity Code', 'Role', 'Active', 'Accredited',
     'Accreditation Expire Date', 'Created', 'Updated']
  end

  def self.ransackable_associations(*)
    authorizable_ransackable_associations
  end

  def self.ransackable_attributes(*)
    authorizable_ransackable_attributes
  end

  private

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
