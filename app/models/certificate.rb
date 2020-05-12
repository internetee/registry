require 'open3'

class Certificate < ApplicationRecord
  include Versions

  belongs_to :api_user

  SIGNED = 'signed'
  UNSIGNED = 'unsigned'
  EXPIRED = 'expired'
  REVOKED = 'revoked'
  VALID = 'valid'

  API = 'api'
  REGISTRAR = 'registrar'
  INTERFACES = [API, REGISTRAR]

  scope 'api', -> { where(interface: API) }
  scope 'registrar', -> { where(interface: REGISTRAR) }

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

  def status
    return UNSIGNED if crt.blank?
    return @cached_status if @cached_status

    @cached_status = SIGNED

    if parsed_crt.not_before > Time.zone.now.utc && parsed_crt.not_after < Time.zone.now.utc
      @cached_status = EXPIRED
    end

    crl = OpenSSL::X509::CRL.new(File.open("#{ENV['crl_dir']}/crl.pem").read)
    return @cached_status unless crl.revoked.map(&:serial).include?(parsed_crt.serial)

    @cached_status = REVOKED
  end

  def sign!
    csr_file = Tempfile.new('client_csr')
    csr_file.write(csr)
    csr_file.rewind

    crt_file = Tempfile.new('client_crt')
    _out, err, _st = Open3.capture3("openssl ca -config #{ENV['openssl_config_path']} -keyfile #{ENV['ca_key_path']} \
    -cert #{ENV['ca_cert_path']} \
    -extensions usr_cert -notext -md sha256 \
    -in #{csr_file.path} -out #{crt_file.path} -key '#{ENV['ca_key_password']}' -batch")

    if err.match?(/Data Base Updated/)
      crt_file.rewind
      self.crt = crt_file.read
      self.md5 = OpenSSL::Digest::MD5.new(parsed_crt.to_der).to_s
      save!
    else
      logger.error('FAILED TO CREATE CLIENT CERTIFICATE')
      if err.match?(/TXT_DB error number 2/)
        errors.add(:base, I18n.t('failed_to_create_crt_csr_already_signed'))
        logger.error('CSR ALREADY SIGNED')
      else
        errors.add(:base, I18n.t('failed_to_create_certificate'))
      end
      logger.error(err)
      puts "Certificate sign issue: #{err.inspect}" if Rails.env.test?
      return false
    end
  end

  def revoke!
    crt_file = Tempfile.new('client_crt')
    crt_file.write(crt)
    crt_file.rewind

    _out, err, _st = Open3.capture3("openssl ca -config #{ENV['openssl_config_path']} -keyfile #{ENV['ca_key_path']} \
      -cert #{ENV['ca_cert_path']} \
      -revoke #{crt_file.path} -key '#{ENV['ca_key_password']}' -batch")

    if err.match(/Data Base Updated/) || err.match(/ERROR:Already revoked/)
      self.revoked = true
      save!
      @cached_status = REVOKED
    else
      errors.add(:base, I18n.t('failed_to_revoke_certificate'))
      logger.error('FAILED TO REVOKE CLIENT CERTIFICATE')
      logger.error(err)
      return false
    end

    self.class.update_registry_crl
    self.class.reload_apache
    self
  end

  class << self
    def update_crl
      update_id_crl
      update_registry_crl
      reload_apache
    end

    def update_id_crl
      STDOUT << "#{Time.zone.now.utc} - Updating ID CRL\n" unless Rails.env.test?

      _out, _err, _st = Open3.capture3("
        mkdir -p #{ENV['crl_dir']}/crl-id-temp
        cd #{ENV['crl_dir']}/crl-id-temp

        wget https://sk.ee/crls/esteid/esteid2007.crl
        wget https://sk.ee/crls/juur/crl.crl
        wget https://sk.ee/crls/eeccrca/eeccrca.crl
        wget https://sk.ee/repository/crls/esteid2011.crl

        openssl crl -in esteid2007.crl -out esteid2007.crl -inform DER
        openssl crl -in crl.crl -out crl.crl -inform DER
        openssl crl -in eeccrca.crl -out eeccrca.crl -inform DER
        openssl crl -in esteid2011.crl -out esteid2011.crl -inform DER

        ln -s crl.crl `openssl crl -hash -noout -in crl.crl`.r0
        ln -s esteid2007.crl `openssl crl -hash -noout -in esteid2007.crl`.r0
        ln -s eeccrca.crl `openssl crl -hash -noout -in eeccrca.crl`.r0
        ln -s esteid2011.crl `openssl crl -hash -noout -in esteid2011.crl`.r0

        rm -rf #{ENV['crl_dir']}/*.crl #{ENV['crl_dir']}/*.r0

        mv #{ENV['crl_dir']}/crl-id-temp/* #{ENV['crl_dir']}

        rm -rf #{ENV['crl_dir']}/crl-id-temp
      ")

      STDOUT << "#{Time.zone.now.utc} - ID CRL updated\n" unless Rails.env.test?
    end

    def update_registry_crl
      STDOUT << "#{Time.zone.now.utc} - Updating registry CRL\n" unless Rails.env.test?

      _out, _err, _st = Open3.capture3("
        mkdir -p #{ENV['crl_dir']}/crl-temp
        cd #{ENV['crl_dir']}/crl-temp

        openssl ca -config #{ENV['openssl_config_path']} -keyfile #{ENV['ca_key_path']} -cert \
        #{ENV['ca_cert_path']} -gencrl -out #{ENV['crl_dir']}/crl-temp/crl.pem -key \
        '#{ENV['ca_key_password']}' -batch

        ln -s crl.pem `openssl crl -hash -noout -in crl.pem`.r1

        rm -rf #{ENV['crl_dir']}/*.pem #{ENV['crl_dir']}/*.r1

        mv #{ENV['crl_dir']}/crl-temp/* #{ENV['crl_dir']}

        rm -rf #{ENV['crl_dir']}/crl-temp
      ")

      STDOUT << "#{Time.zone.now.utc} - Registry CRL updated\n" unless Rails.env.test?
    end

    def reload_apache
      STDOUT << "#{Time.zone.now.utc} - Reloading apache\n" unless Rails.env.test?
      _out, _err, _st = Open3.capture3("sudo /etc/init.d/apache2 reload")
      STDOUT << "#{Time.zone.now.utc} - Apache reloaded\n" unless Rails.env.test?
    end

    def parse_md_from_string(crt)
      return nil if crt.blank?
      crt = crt.split(' ').join("\n")
      crt.gsub!("-----BEGIN\nCERTIFICATE-----\n", "-----BEGIN CERTIFICATE-----\n")
      crt.gsub!("\n-----END\nCERTIFICATE-----", "\n-----END CERTIFICATE-----")
      cert = OpenSSL::X509::Certificate.new(crt)
      OpenSSL::Digest::MD5.new(cert.to_der).to_s
    end
  end
end
