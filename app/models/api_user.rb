require 'open3'

class ApiUser < User
  include EppErrors
  devise :database_authenticatable, :trackable, :timeoutable, :id_card_authenticatable,
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

  class << self
    def find_by_id_card(id_card)
      find_by(identity_code: id_card.personal_code)
    end
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

  def registrar_pki_ok?(crt, cn)
    return false if crt.blank? || cn.blank?
    crt = crt.split(' ').join("\n")
    crt.gsub!("-----BEGIN\nCERTIFICATE-----\n", "-----BEGIN CERTIFICATE-----\n")
    crt.gsub!("\n-----END\nCERTIFICATE-----", "\n-----END CERTIFICATE-----")
    cert = OpenSSL::X509::Certificate.new(crt)
    md5 = OpenSSL::Digest::MD5.new(cert.to_der).to_s
    certificates.registrar.exists?(md5: md5, common_name: cn)
  end

  def api_pki_ok?(crt, cn)
    return false if crt.blank? || cn.blank?
    crt = crt.split(' ').join("\n")
    crt.gsub!("-----BEGIN\nCERTIFICATE-----\n", "-----BEGIN CERTIFICATE-----\n")
    crt.gsub!("\n-----END\nCERTIFICATE-----", "\n-----END CERTIFICATE-----")
    cert = OpenSSL::X509::Certificate.new(crt)
    md5 = OpenSSL::Digest::MD5.new(cert.to_der).to_s
    certificates.api.exists?(md5: md5, common_name: cn)
  end

  def linked_users
    self.class.where(identity_code: identity_code)
      .where("identity_code IS NOT NULL AND identity_code != ''")
      .where.not(id: id)
  end

  def linked_with?(another_api_user)
    another_api_user.identity_code == self.identity_code
  end
end
