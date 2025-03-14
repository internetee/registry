module Certificates
  class CertificateGenerator < Dry::Struct
    attribute :api_user_id, Types::Coercible::Integer
    attribute? :interface, Types::String.optional

    P12_PASSWORD = 'todo-change-me'

    def execute
      api_user = ApiUser.find(api_user_id)

      private_key = generate_user_key
      csr = generate_user_csr(private_key)
      certificate = sign_user_certificate(csr)
      p12 = create_user_p12(private_key, certificate)

      certificate_record = api_user.certificates.build(
        private_key: private_key.to_pem,
        csr: csr.to_pem,
        crt: certificate.to_pem,
        p12: Base64.strict_encode64(p12),
        expires_at: certificate.not_after,
        interface: interface || 'registrar',
        p12_password_digest: P12_PASSWORD,
        serial: certificate.serial.to_s,
        common_name: api_user.username
      )

      certificate_record.save!
      certificate_record
    end

    def self.generate_serial_number
      serial = Time.now.to_i.to_s + Random.rand(10000).to_s.rjust(5, '0')
      
      OpenSSL::BN.new(serial)
    end

    def self.openssl_config_path
      ENV['openssl_config_path'] || Rails.root.join('test/fixtures/files/test_ca/openssl.cnf').to_s
    end
    
    def self.ca_cert_path
      ENV['ca_cert_path'] || Rails.root.join('test/fixtures/files/test_ca/certs/ca.crt.pem').to_s
    end
    
    def self.ca_key_path
      ENV['ca_key_path'] || Rails.root.join('test/fixtures/files/test_ca/private/ca.key.pem').to_s
    end
    
    def self.ca_password
      ENV['ca_key_password'] || '123456'
    end
    
    def ca_cert_path
      self.class.ca_cert_path
    end
    
    def ca_key_path
      self.class.ca_key_path
    end
    
    def ca_password
      self.class.ca_password
    end

    def openssl_config_path
      self.class.openssl_config_path
    end
    
    def username
      @username ||= ApiUser.find(api_user_id).username
    end

    def registrar_name
      @registrar_name ||= ApiUser.find(api_user_id).registrar_name
    end
    
    # openssl genrsa -out ./ca/client/client.key 4096
    def generate_user_key
      OpenSSL::PKey::RSA.new(4096)
    end

    # openssl req -new -key ./ca/client/client.key -out ./ca/client/client.csr -config ./ca/openssl.cnf
    def generate_user_csr(key)
      request = OpenSSL::X509::Request.new
      request.version = 0
      request.subject = OpenSSL::X509::Name.new([
        ['CN', username, OpenSSL::ASN1::UTF8STRING],
        ['OU', 'REGISTRAR', OpenSSL::ASN1::UTF8STRING],
        ['O', registrar_name, OpenSSL::ASN1::UTF8STRING]
      ])
      
      request.public_key = key.public_key
      request.sign(key, OpenSSL::Digest::SHA256.new)
      
      request
    end

    # openssl ca -config ./ca/openssl.cnf -keyfile ./ca/ca.key.pem -cert ./ca/ca_2025.pem -extensions usr_cert -notext -md sha256 -in ./ca/client/client.csr -out ./ca/client/client.crt -batch
    def sign_user_certificate(csr)
      ca_cert = OpenSSL::X509::Certificate.new(File.read(ca_cert_path))
      ca_key = OpenSSL::PKey::RSA.new(File.read(ca_key_path), ca_password)
      
      cert = OpenSSL::X509::Certificate.new
      cert.serial = self.class.generate_serial_number # Используем новый метод генерации серийного номера
      cert.version = 2
      cert.not_before = Time.now
      cert.not_after = Time.now + 365 * 24 * 60 * 60  # 1 год
      
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
      
      cert
    end

    def create_user_p12(key, cert, password = P12_PASSWORD)
      ca_cert = OpenSSL::X509::Certificate.new(File.read(ca_cert_path))

      p12 = OpenSSL::PKCS12.create(
        password,
        username,
        key,
        cert,
        [ca_cert]
      )
      
      p12.to_der
    end
  end
end