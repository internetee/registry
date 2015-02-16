require 'open3'

# rubocop: disable Metrics/ClassLength
class ApiUser < User
  # TODO: should have max request limit per day
  belongs_to :registrar
  has_many :contacts

  validates :username, :password, :registrar, presence: true
  validates :username, uniqueness: true

  before_save :create_crt, if: -> (au) { au.csr_changed? }

  attr_accessor :registrar_typeahead

  def ability
    @ability ||= Ability.new(self)
  end
  delegate :can?, :cannot?, to: :ability

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
    csr_file = Tempfile.new('client_csr')
    csr_file.write(csr)
    csr_file.rewind

    crt_file = Tempfile.new('client_crt')
    _out, err, _st = Open3.capture3("openssl ca -keyfile #{APP_CONFIG['ca_key_path']} \
    -cert #{APP_CONFIG['ca_cert_path']} \
    -extensions usr_cert -notext -md sha256 \
    -in #{csr_file.path} -out #{crt_file.path} -key '#{APP_CONFIG['ca_key_password']}' -batch")

    if err.match(/Data Base Updated/)
      crt_file.rewind
      self.crt = crt_file.read
      return true
    else
      errors.add(:base, I18n.t('failed_to_create_certificate'))
      logger.error('FAILED TO CREATE CLIENT CERTIFICATE')
      logger.error(err)
      return false
    end
  end
end
# rubocop: enable Metrics/ClassLength
