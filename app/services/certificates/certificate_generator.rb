module Certificates
  class CertificateGenerator < Dry::Struct
    attribute :username, Types::Strict::String
    attribute :registrar_code, Types::Coercible::String
    attribute :registrar_name, Types::Strict::String
    attribute? :user_csr, Types::String.optional
    attribute? :certificate, Types::Any.optional
    attribute? :private_key, Types::String.optional
    attribute :interface, Types::String.default('registrar')

    CERTS_PATH = Rails.root.join('certs')
    CA_PATH = CERTS_PATH.join('ca')
    
    # User certificate files
    USER_CSR_NAME = 'user.csr'
    USER_KEY_NAME = 'user.key'
    USER_CRT_NAME = 'user.crt'
    USER_P12_NAME = 'user.p12'
    
    # CA files
    CA_CERT_PATHS = {
      'api' => CA_PATH.join('certs/ca_epp.crt.pem'),
      'registrar' => CA_PATH.join('certs/ca_portal.crt.pem')
    }.freeze
    CA_KEY_PATHS = {
      'api' => CA_PATH.join('private/ca_epp.key.pem'),
      'registrar' => CA_PATH.join('private/ca_portal.key.pem')
    }.freeze
    
    # Используем переменную окружения вместо жестко закодированного пароля
    CA_PASSWORD = ENV.fetch('CA_PASSWORD', '123456')
    
    # CRL file
    CRL_DIR = CA_PATH.join('crl')
    CRL_PATH = CRL_DIR.join('crl.pem')

    def initialize(*)
      super
      Rails.logger.info("Initializing CertificateGenerator for user: #{username}, interface: #{interface}")
      ensure_directories_exist
      ensure_ca_exists
      ensure_crl_exists
    end

    def call
      Rails.logger.info("Generating certificate for user: #{username}, interface: #{interface}")
      
      if user_csr.present?
        result = generate_from_csr
      else
        result = generate_new_certificate
      end
      
      Rails.logger.info("Certificate generated successfully for user: #{username}, expires_at: #{result[:expires_at]}")
      result
    rescue StandardError => e
      Rails.logger.error("Error generating certificate: #{e.message}")
      Rails.logger.error(e.backtrace.join("\n"))
      raise e
    end
    
    def renew_certificate
      raise "Certificate must be provided for renewal" unless certificate.present?
      Rails.logger.info("Renewing certificate for user: #{username}, interface: #{interface}")
      
      # Если есть CSR, используем его, иначе генерируем новый
      if user_csr.present?
        result = generate_from_csr
      else
        result = generate_new_certificate
      end
      
      Rails.logger.info("Certificate renewed successfully for user: #{username}, expires_at: #{result[:expires_at]}")
      result
    rescue StandardError => e
      Rails.logger.error("Error renewing certificate: #{e.message}")
      Rails.logger.error(e.backtrace.join("\n"))
      raise e
    end

    private
    
    def generate_from_csr
      csr = OpenSSL::X509::Request.new(user_csr)
      cert = sign_certificate(csr)
      
      {
        private_key: nil,
        csr: csr.to_pem,
        crt: cert.to_pem,
        p12: nil,
        expires_at: cert.not_after
      }
    end
    
    def generate_new_certificate
      csr, key = generate_csr_and_key
      cert = sign_certificate(csr)
      p12 = create_p12(key, cert)

      {
        private_key: key.export(OpenSSL::Cipher.new('AES-256-CBC'), CA_PASSWORD),
        csr: csr.to_pem,
        crt: cert.to_pem,
        p12: p12.to_der,
        expires_at: cert.not_after
      }
    end

    def generate_csr_and_key
      key = OpenSSL::PKey::RSA.new(4096)
      
      request = OpenSSL::X509::Request.new
      request.version = 0
      request.subject = OpenSSL::X509::Name.new([
        ['CN', username, OpenSSL::ASN1::UTF8STRING],
        ['OU', registrar_code, OpenSSL::ASN1::UTF8STRING],
        ['O', registrar_name, OpenSSL::ASN1::UTF8STRING]
      ])
      
      request.public_key = key.public_key
      request.sign(key, OpenSSL::Digest::SHA256.new)
      
      save_csr(request)
      save_private_key(key.export(OpenSSL::Cipher.new('AES-256-CBC'), CA_PASSWORD))
      
      [request, key]
    end

    def sign_certificate(csr)
      Rails.logger.info("Signing certificate for request with subject: #{csr.subject}")
      
      ca_key = OpenSSL::PKey::RSA.new(File.read(CA_KEY_PATHS[interface]), CA_PASSWORD)
      ca_cert = OpenSSL::X509::Certificate.new(File.read(CA_CERT_PATHS[interface]))

      cert = OpenSSL::X509::Certificate.new
      cert.serial = generate_unique_serial
      cert.version = 2
      cert.not_before = Time.now
      cert.not_after = Time.now + 365 * 24 * 60 * 60 # 1 year

      cert.subject = csr.subject
      cert.public_key = csr.public_key
      cert.issuer = ca_cert.subject

      extension_factory = OpenSSL::X509::ExtensionFactory.new
      extension_factory.subject_certificate = cert
      extension_factory.issuer_certificate = ca_cert

      cert.add_extension(extension_factory.create_extension("basicConstraints", "CA:FALSE"))
      cert.add_extension(extension_factory.create_extension("keyUsage", "nonRepudiation,digitalSignature,keyEncipherment"))
      cert.add_extension(extension_factory.create_extension("subjectKeyIdentifier", "hash"))

      cert.sign(ca_key, OpenSSL::Digest::SHA256.new)
      save_certificate(cert)
      
      cert
    end

    def create_p12(key, cert)
      ca_cert = OpenSSL::X509::Certificate.new(File.read(CA_CERT_PATHS[interface]))
      
      p12 = OpenSSL::PKCS12.create(
        nil, # password
        username,
        key,
        cert,
        [ca_cert]
      )
      
      File.open(CERTS_PATH.join(USER_P12_NAME), 'wb') do |file|
        file.write(p12.to_der)
      end
      
      p12
    end

    def ensure_directories_exist
      FileUtils.mkdir_p(CERTS_PATH)
      FileUtils.mkdir_p(CA_PATH.join('certs'))
      FileUtils.mkdir_p(CA_PATH.join('private'))
      FileUtils.mkdir_p(CRL_DIR)
      FileUtils.chmod(0700, CA_PATH.join('private'))
    end

    def ensure_ca_exists
      # Проверяем наличие файлов CA, но не создаем их каждый раз
      Certificate::INTERFACES.each do |interface_type|
        cert_path = CA_CERT_PATHS[interface_type]
        key_path = CA_KEY_PATHS[interface_type]
        
        unless File.exist?(cert_path) && File.exist?(key_path)
          Rails.logger.warn("CA certificate or key missing for interface: #{interface_type}. Please create them manually.")
          # Не создаем новые CA, а выводим предупреждение
        end
      end
    end

    def ensure_crl_exists
      return if File.exist?(CRL_PATH)
      
      Rails.logger.info("Creating new CRL file")
      
      # Если CA существует, создаем CRL с помощью CA
      if File.exist?(CA_CERT_PATHS[interface]) && File.exist?(CA_KEY_PATHS[interface])
        ca_key = OpenSSL::PKey::RSA.new(File.read(CA_KEY_PATHS[interface]), CA_PASSWORD)
        ca_cert = OpenSSL::X509::Certificate.new(File.read(CA_CERT_PATHS[interface]))
        
        crl = OpenSSL::X509::CRL.new
        crl.version = 1
        crl.issuer = ca_cert.subject
        crl.last_update = Time.now
        crl.next_update = Time.now + 365 * 24 * 60 * 60 # 1 year
        
        ef = OpenSSL::X509::ExtensionFactory.new
        ef.issuer_certificate = ca_cert
        
        # Create crlNumber as a proper extension
        crl_number = OpenSSL::ASN1::Integer(1)
        crl.add_extension(OpenSSL::X509::Extension.new("crlNumber", crl_number.to_der))
        
        crl.sign(ca_key, OpenSSL::Digest::SHA256.new)
        
        File.open(CRL_PATH, 'wb') do |file|
          file.write(crl.to_pem)
        end
      else
        # Если CA не существует, создаем пустой файл CRL
        File.open(CRL_PATH, 'wb') do |file|
          file.write("")
        end
      end
    end

    def generate_unique_serial
      # Генерируем случайный серийный номер
      # Используем текущее время в микросекундах и случайное число
      # для обеспечения уникальности
      (Time.now.to_f * 1000000).to_i + SecureRandom.random_number(1000000)
    end

    def save_private_key(encrypted_key)
      path = CERTS_PATH.join(USER_KEY_NAME)
      File.write(path, encrypted_key)
      FileUtils.chmod(0600, path)
    end

    def save_csr(request)
      File.write(CERTS_PATH.join(USER_CSR_NAME), request.to_pem)
    end

    def save_certificate(certificate)
      File.write(CERTS_PATH.join(USER_CRT_NAME), certificate.to_pem)
    end
  end
end