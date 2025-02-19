module Certificates
  class CertificateGenerator < Dry::Struct
    attribute :username, Types::Strict::String
    attribute :registrar_code, Types::Coercible::String
    attribute :registrar_name, Types::Strict::String

    CERTS_PATH = Rails.root.join('certs')
    CA_PATH = CERTS_PATH.join('ca')
    
    # User certificate files
    USER_CSR_NAME = 'user.csr'
    USER_KEY_NAME = 'user.key'
    USER_CRT_NAME = 'user.crt'
    USER_P12_NAME = 'user.p12'
    
    # CA files
    CA_CERT_PATH = CA_PATH.join('certs/ca.crt.pem')
    CA_KEY_PATH = CA_PATH.join('private/ca.key.pem')
    CA_PASSWORD = '123456'

    def initialize(*)
      super
      ensure_directories_exist
    end

    def call
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

    private

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
      ca_key = OpenSSL::PKey::RSA.new(File.read(CA_KEY_PATH), CA_PASSWORD)
      ca_cert = OpenSSL::X509::Certificate.new(File.read(CA_CERT_PATH))

      cert = OpenSSL::X509::Certificate.new
      cert.serial = 0
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
      ca_cert = OpenSSL::X509::Certificate.new(File.read(CA_CERT_PATH))
      
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

    private

    def ensure_directories_exist
      FileUtils.mkdir_p(CERTS_PATH)
      FileUtils.mkdir_p(CA_PATH.join('certs'))
      FileUtils.mkdir_p(CA_PATH.join('private'))
      FileUtils.chmod(0700, CA_PATH.join('private'))
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