require 'open3'

class Certificate < ApplicationRecord
  include Versions
  include Certificate::CertificateConcern

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

  validates :interface, inclusion: { in: INTERFACES }

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

    parse_metadata(certificate_origin)
  rescue NoMethodError
    errors.add(:base, I18n.t(:invalid_csr_or_crt))
  end

  validate :check_active_certificates, on: :create
  def check_active_certificates
    return unless api_user && interface
    
    active_certs = api_user.certificates.where(interface: interface, revoked: false)
                          .where('expires_at > ?', Time.current)
    
    if active_certs.exists?
      errors.add(:base, I18n.t('certificate.errors.active_certificate_exists'))
    end
  end

  validate :check_ca_certificate, if: -> { crt.present? }
  def check_ca_certificate
    begin
      cert = parsed_crt
      return if cert.nil?
      
      # Получаем правильный CA для интерфейса
      ca_cert_path = interface == API ? 
        Certificates::CertificateGenerator::CA_CERT_PATHS['api'] : 
        Certificates::CertificateGenerator::CA_CERT_PATHS['registrar']
      
      ca_cert = OpenSSL::X509::Certificate.new(File.read(ca_cert_path))
      
      # Проверяем, что сертификат подписан правильным CA
      unless cert.issuer.to_s == ca_cert.subject.to_s
        errors.add(:base, I18n.t('certificate.errors.invalid_ca'))
      end
    rescue StandardError => e
      Rails.logger.error("Error checking CA: #{e.message}")
      errors.add(:base, I18n.t('certificate.errors.ca_check_failed'))
    end
  end

  def parsed_crt
    @p_crt ||= OpenSSL::X509::Certificate.new(crt) if crt
  end

  def parsed_csr
    @p_csr ||= OpenSSL::X509::Request.new(csr) if csr
  end

  def parsed_private_key
    return nil if private_key.blank?
    
    decoded_key = Base64.decode64(private_key)
    OpenSSL::PKey::RSA.new(decoded_key, Certificates::CertificateGenerator::CA_PASSWORD)
  rescue OpenSSL::PKey::RSAError
    nil
  end

  def parsed_p12
    return nil if p12.blank?
    
    decoded_p12 = Base64.decode64(p12)
    OpenSSL::PKCS12.new(decoded_p12)
  rescue OpenSSL::PKCS12::PKCS12Error
    nil
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

    begin
      err_output = execute_openssl_sign_command(password, csr_file.path, crt_file.path)

      update_certificate_details(crt_file) and return true if err_output.match?(/Data Base Updated/)

      log_failed_to_create_certificate(err_output)
      false
    ensure
      # Make sure to close and unlink the tempfiles to prevent leaks
      csr_file.close
      csr_file.unlink
      crt_file.close
      crt_file.unlink
    end
  end

  def revoke!(password:)
    crt_file = create_tempfile('client_crt', crt)

    begin
      err_output = execute_openssl_revoke_command(password, crt_file.path)

      if revocation_successful?(err_output)
        update_revocation_status
        self.class.update_crl
        return self
      end

      handle_revocation_failure(err_output)
    ensure
      # Make sure to close and unlink the tempfile to prevent leaks
      crt_file.close
      crt_file.unlink
    end
  end

  def renewable?
    return false if revoked?
    return false if crt.blank?
    return false if expires_at.blank?
    
    expires_at > Time.current && expires_at <= 30.days.from_now
  end

  def expired?
    return false if revoked?
    return false if crt.blank?
    return false if expires_at.blank?
    
    expires_at < Time.current
  end

  def renew
    raise "Certificate cannot be renewed" unless renewable?

    generator = Certificates::CertificateGenerator.new(
      username: api_user.username,
      registrar_code: api_user.registrar_code,
      registrar_name: api_user.registrar_name,
      certificate: self
    )

    generator.renew_certificate
  end

  def self.generate_for_api_user(api_user:, interface: 'api')
    # Проверяем наличие активных сертификатов
    active_certs = api_user.certificates.where(interface: interface, revoked: false)
                          .where('expires_at > ?', Time.current)
    
    if active_certs.exists?
      Rails.logger.warn("User #{api_user.username} already has an active certificate for interface #{interface}")
      return active_certs.first
    end

    generator = Certificates::CertificateGenerator.new(
      username: api_user.username,
      registrar_code: api_user.registrar_code,
      registrar_name: api_user.registrar_name,
      interface: interface
    )
    
    cert_data = generator.call
    
    create!(
      api_user: api_user,
      interface: interface,
      private_key: Base64.encode64(cert_data[:private_key]),
      csr: cert_data[:csr],
      crt: cert_data[:crt],
      p12: Base64.encode64(cert_data[:p12]),
      expires_at: cert_data[:expires_at],
      revoked: false
    )
  end

  private

  def certificate_origin
    crt ? parsed_crt : parsed_csr
  end

  def parse_metadata(origin)
    pc = origin.subject.to_s
    cn = pc.scan(%r{\/CN=(.+)}).flatten.first
    self.common_name = cn.split('/').first
    self.md5 = OpenSSL::Digest::MD5.new(origin.to_der).to_s if crt
    self.interface = crt ? API : REGISTRAR
  end

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
    parsed_crt.not_after < Time.zone.now.utc
  end

  def certificate_revoked?
    return true if revoked
    
    begin
      crl_path = "#{ENV['crl_dir']}/crl.pem"
      return false unless File.exist?(crl_path)
      
      crl_content = File.read(crl_path)
      return false if crl_content.blank?
      
      crl = OpenSSL::X509::CRL.new(crl_content)
      
      # Make sure we can read the serial from the certificate
      begin
        cert_serial = parsed_crt.serial
        return crl.revoked.any? { |revoked_cert| revoked_cert.serial == cert_serial }
      rescue StandardError => e
        Rails.logger.error("Error checking certificate serial: #{e.message}")
        return false
      end
    rescue StandardError => e
      Rails.logger.error("Error checking CRL: #{e.message}")
      return false
    end
  end
end
