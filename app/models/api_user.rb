# rubocop: disable Metrics/ClassLength
class ApiUser < ActiveRecord::Base
  include Versions # version/api_user_version.rb
  # TODO: should have max request limit per day
  belongs_to :registrar
  has_many :contacts

  validates :username, :password, :registrar, presence: true
  validates :username, uniqueness: true

  before_save :create_crt, if: -> (au) { au.csr_changed? }

  attr_accessor :registrar_typeahead

  def registrar_typeahead
    @registrar_typeahead || registrar || nil
  end

  def to_s
    username
  end

  def queued_messages
    registrar.messages.queued
  end

  def create_crt
    request = OpenSSL::X509::Request.new(csr)
    fail 'CSR can not be verified' unless request.verify request.public_key
    ca_cert = OpenSSL::X509::Certificate.new(File.read(APP_CONFIG['ca_cert_path']))
    ca_key = OpenSSL::PKey::RSA.new(File.read(APP_CONFIG['ca_key_path']), APP_CONFIG['ca_key_password'])

    csr_cert = OpenSSL::X509::Certificate.new
    csr_cert.serial = 0
    csr_cert.version = 2
    csr_cert.not_before = Time.now
    csr_cert.not_after = Time.now + 600

    csr_cert.subject = request.subject
    csr_cert.public_key = request.public_key
    csr_cert.issuer = ca_cert.subject

    extension_factory = OpenSSL::X509::ExtensionFactory.new
    extension_factory.subject_certificate = csr_cert
    extension_factory.issuer_certificate = ca_cert

    csr_cert.add_extension extension_factory.create_extension('basicConstraints', 'CA:FALSE')

    csr_cert.add_extension extension_factory.create_extension(
        'keyUsage', 'keyEncipherment,dataEncipherment,digitalSignature')

    csr_cert.add_extension extension_factory.create_extension('subjectKeyIdentifier', 'hash')

    csr_cert.sign ca_key, OpenSSL::Digest::SHA1.new

    self.crt = csr_cert.to_pem
  end
end
# rubocop: enable Metrics/ClassLength
