class Certificate < ActiveRecord::Base
  include Versions

  belongs_to :api_user

  SIGNED = 'signed'
  UNSIGNED = 'unsigned'
  EXPIRED = 'expired'
  REVOKED = 'revoked'
  VALID = 'valid'

  validates :csr, presence: true

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

    crl = OpenSSL::X509::CRL.new(File.open(ENV['crl_path']).read)
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

    if err.match(/Data Base Updated/)
      crt_file.rewind
      self.crt = crt_file.read
      save!
    else
      errors.add(:base, I18n.t('failed_to_create_certificate'))
      logger.error('FAILED TO CREATE CLIENT CERTIFICATE')
      logger.error(err)
      # rubocop:disable Rails/Output
      puts "Certificate sign issue: #{err.inspect}" if Rails.env.test? 
      # rubocop:enable Rails/Output
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
      save!
      @cached_status = REVOKED
    else
      errors.add(:base, I18n.t('failed_to_revoke_certificate'))
      logger.error('FAILED TO REVOKE CLIENT CERTIFICATE')
      logger.error(err)
      return false
    end

    _out, _err, _st = Open3.capture3("openssl ca -config #{ENV['openssl_config_path']} -keyfile #{ENV['ca_key_path']} \
      -cert #{ENV['ca_cert_path']} \
      -gencrl -out #{ENV['crl_path']} -key '#{ENV['ca_key_password']}' -batch")
  end
end
