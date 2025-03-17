require 'test_helper'

module Certificates
  class CertificateGeneratorTest < ActiveSupport::TestCase
    test "generate client private key" do
      generator = CertificateGenerator.new(api_user_id: users(:api_bestnames).id)
      private_key = generator.generate_user_key

      assert_instance_of OpenSSL::PKey::RSA, private_key
      assert_equal 4096, private_key.n.num_bits
    end

    test "generate client csr" do
      generator = CertificateGenerator.new(api_user_id: users(:api_bestnames).id)
      private_key = generator.generate_user_key
      csr = generator.generate_user_csr(private_key)

      assert_instance_of OpenSSL::X509::Request, csr
      assert csr.verify(csr.public_key)
      assert_equal "/CN=#{generator.username}/OU=REGISTRAR/O=#{generator.registrar_name}", csr.subject.to_s
    end

    test "generate client ctr" do
      generator = CertificateGenerator.new(api_user_id: users(:api_bestnames).id)
      private_key = generator.generate_user_key
      csr = generator.generate_user_csr(private_key)
      certificate = generator.sign_user_certificate(csr)

      ca_cert = OpenSSL::X509::Certificate.new(File.read(generator.ca_cert_path))

      assert_instance_of OpenSSL::X509::Certificate, certificate
      assert_equal csr.subject.to_s, certificate.subject.to_s
      assert_equal 2, certificate.version
      assert certificate.verify(ca_cert.public_key)
    end

    test "generate client p12" do
      generator = CertificateGenerator.new(api_user_id: users(:api_bestnames).id)
      private_key = generator.generate_user_key
      csr = generator.generate_user_csr(private_key)
      certificate = generator.sign_user_certificate(csr)

      p12 = generator.create_user_p12(private_key, certificate)
      
      # Verify P12 can be loaded back with correct password
      loaded_p12 = OpenSSL::PKCS12.new(p12, CertificateGenerator::P12_PASSWORD)
      
      assert_instance_of OpenSSL::PKCS12, loaded_p12
      assert_equal certificate.to_der, loaded_p12.certificate.to_der
      assert_equal private_key.to_der, loaded_p12.key.to_der
    end

    test "serial number should be created for each certificate" do
      generator = CertificateGenerator.new(api_user_id: users(:api_bestnames).id)
      
      # Generate two certificates and compare their serial numbers
      csr1 = generator.generate_user_csr(generator.generate_user_key)
      cert1 = generator.sign_user_certificate(csr1)
      serial1 = cert1.serial.to_s(16) # Convert to hex string
      
      csr2 = generator.generate_user_csr(generator.generate_user_key)
      cert2 = generator.sign_user_certificate(csr2)
      serial2 = cert2.serial.to_s(16) # Convert to hex string
      
      assert_not_equal serial1, serial2
      assert_match(/^[0-9A-Fa-f]+$/, serial1)
      assert_match(/^[0-9A-Fa-f]+$/, serial2)
    end

    test "generated data should be store in database" do
      generator = CertificateGenerator.new(api_user_id: users(:api_bestnames).id)
      certificate_record = generator.execute

      assert certificate_record.persisted?
      assert_not_nil certificate_record.private_key
      assert_not_nil certificate_record.csr
      assert_not_nil certificate_record.crt
      assert_not_nil certificate_record.p12
      assert_equal 'registrar', certificate_record.interface
      assert_equal CertificateGenerator::P12_PASSWORD, certificate_record.p12_password_digest
      assert_equal users(:api_bestnames).username, certificate_record.common_name
      
      # Verify the certificate can be parsed back from stored data
      cert = OpenSSL::X509::Certificate.new(certificate_record.crt)
      assert_equal certificate_record.serial, cert.serial.to_s
      assert_equal certificate_record.expires_at.to_i, cert.not_after.to_i
    end
  end
end 
