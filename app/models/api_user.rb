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

  delegate :code, :name, to: :registrar, prefix: true
  delegate :legaldoc_mandatory?, to: :registrar

  alias_attribute :login, :username

  SUPER = 'super'
  EPP = 'epp'
  BILLING = 'billing'

  ROLES = %w(super epp billing) # should not match to admin roles

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
    self.class.where(identity_code: identity_code)
      .where("identity_code IS NOT NULL AND identity_code != ''")
      .where.not(id: id)
  end

  def linked_with?(another_api_user)
    another_api_user.identity_code == self.identity_code
  end

  private

  def machine_readable_certificate(cert)
    cert = cert.split(' ').join("\n")
    cert.gsub!("-----BEGIN\nCERTIFICATE-----\n", "-----BEGIN CERTIFICATE-----\n")
    cert.gsub!("\n-----END\nCERTIFICATE-----", "\n-----END CERTIFICATE-----")

    OpenSSL::X509::Certificate.new(cert)
  end
end
