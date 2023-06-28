require 'open3'

class Certificate < ApplicationRecord
  include Versions

  belongs_to :api_user

  SIGNED = 'signed'.freeze
  UNSIGNED = 'unsigned'.freeze
  EXPIRED = 'expired'.freeze
  REVOKED = 'revoked'.freeze
  VALID = 'valid'.freeze

  API = 'api'.freeze
  REGISTRAR = 'registrar'.freeze
  INTERFACES = [API, REGISTRAR].freeze

  scope 'api', -> { where(interface: API) }
  scope 'registrar', -> { where(interface: REGISTRAR) }
  scope 'unrevoked', -> { where(revoked: false) }

  validate :validate_csr_and_crt_presence
  def validate_csr_and_crt_presence
    return if csr.try(:scrub).present? || crt.try(:scrub).present?

    errors.add(:base, I18n.t(:crt_or_csr_must_be_present))
  end

  validate :validate_csr_and_crt
  def validate_csr_and_crt
    parsed_crt
    parsed_csr
  rescue OpenSSL::X509::RequestError, OpenSSL::X509::CertificateError
    errors.add(:base, I18n.t(:invalid_csr_or_crt))
  end

  validate :assign_metadata, on: :create

  def assign_metadata
    return if errors.any?

    origin = crt ? parsed_crt : parsed_csr
    parse_metadata(origin)
  rescue NoMethodError
    errors.add(:base, I18n.t(:invalid_csr_or_crt))
  end

  def parse_metadata(origin)
    pc = origin.subject.to_s
    cn = pc.scan(%r{\/CN=(.+)}).flatten.first
    self.common_name = cn.split('/').first
    self.md5 = OpenSSL::Digest::MD5.new(origin.to_der).to_s if crt
    self.interface = crt ? API : REGISTRAR
  end

  def parsed_crt
    @p_crt ||= OpenSSL::X509::Certificate.new(crt) if crt
  end

  def parsed_csr
    @p_csr ||= OpenSSL::X509::Request.new(csr) if csr
  end

  def revoked?
    status == REVOKED
  end

  def revokable?
    interface == REGISTRAR && status != UNSIGNED
  end

  def status
    return UNSIGNED if crt.blank?
    return @cached_status if @cached_status

    @cached_status = SIGNED

    if certificate_expired?
      @cached_status = EXPIRED
    elsif certificate_revoked?
      @cached_status = REVOKED
    end

    @cached_status
  end

  def sign!(password:)
    csr_file = create_tempfile('client_csr', csr)
    crt_file = Tempfile.new('client_crt')

    err_output = execute_openssl_sign_command(password, csr_file.path, crt_file.path)

    update_certificate_details(crt_file) and return true if err_output.match?(/Data Base Updated/)

    log_failed_to_create_certificate(err_output)
    false
  end

  def revoke!(password:)
    crt_file = create_tempfile('client_crt', crt)

    err_output = execute_openssl_revoke_command(password, crt_file.path)

    if revocation_successful?(err_output)
      update_revocation_status
      self.class.update_crl
      return self
    end

    handle_revocation_failure(err_output)
  end

  class << self
    def tostdout(message)
      time = Time.zone.now.utc
      $stdout << "#{time} - #{message}\n" unless Rails.env.test?
    end

    def update_crl
      tostdout('Running crlupdater')
      system('/bin/bash', ENV['crl_updater_path'].to_s)
      tostdout('Finished running crlupdater')
    end

    def parse_md_from_string(crt)
      return if crt.blank?

      crt = crt.split(' ').join("\n")
      crt.gsub!("-----BEGIN\nCERTIFICATE-----\n", "-----BEGIN CERTIFICATE-----\n")
      crt.gsub!("\n-----END\nCERTIFICATE-----", "\n-----END CERTIFICATE-----")
      cert = OpenSSL::X509::Certificate.new(crt)
      OpenSSL::Digest::MD5.new(cert.to_der).to_s
    end
  end

  private

  def create_tempfile(filename, content = '')
    tempfile = Tempfile.new(filename)
    tempfile.write(content)
    tempfile.rewind
    tempfile
  end

  def log_failed_to_create_certificate(err_output)
    logger.error('FAILED TO CREATE CLIENT CERTIFICATE')
    if err_output.match?(/TXT_DB error number 2/)
      handle_csr_already_signed_error
    else
      errors.add(:base, I18n.t('failed_to_create_certificate'))
    end
    logger.error(err_output)
    puts "Certificate sign issue: #{err_output.inspect}" if Rails.env.test?
  end

  def execute_openssl_sign_command(password, csr_path, crt_path)
    openssl_command = [
      'openssl', 'ca', '-config', ENV['openssl_config_path'],
      '-keyfile', ENV['ca_key_path'], '-cert', ENV['ca_cert_path'],
      '-extensions', 'usr_cert', '-notext', '-md', 'sha256',
      '-in', csr_path, '-out', crt_path,
      '-key', password,
      '-batch'
    ]

    _out, err, _st = Open3.capture3(*openssl_command)
    err
  end

  def execute_openssl_revoke_command(password, crt_path)
    openssl_command = [
      'openssl', 'ca', '-config', ENV['openssl_config_path'],
      '-keyfile', ENV['ca_key_path'], '-cert', ENV['ca_cert_path'],
      '-revoke', crt_path,
      '-key', password,
      '-batch'
    ]

    _out, err, _st = Open3.capture3(*openssl_command)
    err
  end

  def update_certificate_details(crt_file)
    crt_file.rewind
    self.crt = crt_file.read
    self.md5 = OpenSSL::Digest::MD5.new(parsed_crt.to_der).to_s
    save!
  end

  def handle_csr_already_signed_error
    errors.add(:base, I18n.t('failed_to_create_crt_csr_already_signed'))
    logger.error('CSR ALREADY SIGNED')
  end

  def handle_revocation_failure(err_output)
    errors.add(:base, I18n.t('failed_to_revoke_certificate'))
    logger.error('FAILED TO REVOKE CLIENT CERTIFICATE')
    logger.error(err_output)
    false
  end

  def revocation_successful?(err_output)
    err_output.match?(/Data Base Updated/) || err_output.match?(/ERROR:Already revoked/)
  end

  def update_revocation_status
    self.revoked = true
    save!
    @cached_status = REVOKED
  end

  def certificate_expired?
    parsed_crt.not_before > Time.zone.now.utc && parsed_crt.not_after < Time.zone.now.utc
  end

  def certificate_revoked?
    crl = OpenSSL::X509::CRL.new(File.open("#{ENV['crl_dir']}/crl.pem").read)
    crl.revoked.map(&:serial).include?(parsed_crt.serial)
  end
end
