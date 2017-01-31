require 'open3'

class ApiUser < User
  include EppErrors

  def epp_code_map
    {
      '2306' => [ # Parameter policy error
        [:password, :blank]
      ]
    }
  end

  def self.min_password_length # Must precede .validates
    6
  end

  # TODO: should have max request limit per day?
  belongs_to :registrar
  has_many :certificates

  validates :username, :password, :registrar, :roles, presence: true
  validates :password, length: { minimum: min_password_length }
  validates :username, uniqueness: true

  # TODO: probably cache, because it's requested on every EPP
  delegate :code, to: :registrar, prefix: true

  attr_accessor :registrar_typeahead

  SUPER = 'super'
  EPP = 'epp'

  ROLES = %w(super epp billing) # should not match to admin roles

  def ability
    @ability ||= Ability.new(self)
  end
  delegate :can?, :cannot?, to: :ability

  after_initialize :set_defaults
  def set_defaults
    return unless new_record?
    self.active = true unless active_changed?
  end

  class << self
    def find_by_idc_data(idc_data)
      return false if idc_data.blank?
      identity_code = idc_data.scan(/serialNumber=(\d+)/).flatten.first

      find_by(identity_code: identity_code)
    end

    def all_by_identity_code(identity_code)
      ApiUser.where(identity_code: identity_code)
        .where("identity_code is NOT NULL and identity_code != ''").includes(:registrar)
    end
  end

  def registrar_typeahead
    @registrar_typeahead || registrar || nil
  end

  def to_s
    username
  end

  def name
    username
  end

  def queued_messages
    registrar.messages.queued
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
end
