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
    csr_file = Tempfile.new('client_csr')
    csr_file.write(csr)
    csr_file.rewind

    crt_file = Tempfile.new('client_crt')

    `openssl ca -keyfile #{APP_CONFIG['ca_key_path']} -cert #{APP_CONFIG['ca_cert_path']} \
    -extensions usr_cert -notext -md sha256 \
    -in #{csr_file.path} -out #{crt_file.path} -key '#{APP_CONFIG['ca_key_password']}' -batch`

    crt_file.rewind
    self.crt = crt_file.read
  end
end
# rubocop: enable Metrics/ClassLength
