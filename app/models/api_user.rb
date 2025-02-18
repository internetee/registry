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
  has_many :user_certificates

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
    cert = cert.split(' ').join("\n")
    cert.gsub!("-----BEGIN\nCERTIFICATE-----\n", "-----BEGIN CERTIFICATE-----\n")
    cert.gsub!("\n-----END\nCERTIFICATE-----", "\n-----END CERTIFICATE-----")

    OpenSSL::X509::Certificate.new(cert)
  end
end
