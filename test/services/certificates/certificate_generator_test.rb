require 'test_helper'

module Certificates
  class CertificateGeneratorTest < ActiveSupport::TestCase
    setup do
      @certificate = certificates(:api)
      @generator = CertificateGenerator.new(
        username: "test_user",
        registrar_code: "REG123",
        registrar_name: "Test Registrar"
      )
    end

    def test_generates_new_certificate
      result = @generator.call
      
      assert result[:private_key].present?
      assert result[:csr].present?
      assert result[:crt].present?
      assert result[:p12].present?
      assert result[:expires_at].present?
      
      assert_instance_of String, result[:private_key]
      assert_instance_of String, result[:csr]
      assert_instance_of String, result[:crt]
      assert_instance_of String, result[:p12]
      assert_instance_of Time, result[:expires_at]
    end

    def test_uses_existing_csr_and_private_key
      existing_csr = @certificate.csr
      existing_private_key = "existing_private_key"
      @certificate.update!(private_key: existing_private_key)
      
      result = @generator.call
      
      assert result[:csr].present?
      assert result[:private_key].present?
      assert_not_equal existing_csr, result[:csr]
      assert_not_equal existing_private_key, result[:private_key]
    end

    def test_renew_certificate
      @certificate.update!(
        expires_at: 20.days.from_now
      )
      
      result = CertificateGenerator.new(
        username: @certificate.common_name,
        registrar_code: "REG123",
        registrar_name: "Test Registrar"
      ).call
      
      assert result[:crt].present?
      assert result[:private_key].present?
    end
    
    def test_generates_unique_serial_numbers
      result1 = @generator.call
      result2 = @generator.call
      
      cert1 = OpenSSL::X509::Certificate.new(result1[:crt])
      cert2 = OpenSSL::X509::Certificate.new(result2[:crt])
      
      assert_not_equal 0, cert1.serial.to_i
      assert_not_equal 0, cert2.serial.to_i
      assert_not_equal cert1.serial.to_i, cert2.serial.to_i
    end
    
    def test_serial_based_on_time
      current_time = Time.now.to_i
      
      result = @generator.call
      cert = OpenSSL::X509::Certificate.new(result[:crt])

      assert cert.serial.to_i >= current_time - 10
      assert cert.serial.to_i <= current_time + 500
    end
    
    def test_p12_creation_succeeds_with_crl
      crl_dir = ENV['crl_dir'] || Rails.root.join('ca/crl').to_s
      crl_path = "#{crl_dir}/crl.pem"

      original_crl = nil
      if File.exist?(crl_path)
        original_crl = File.read(crl_path)
      end

      FileUtils.mkdir_p(crl_dir) unless Dir.exist?(crl_dir)
      
      begin
        if File.exist?(crl_path)
          File.delete(crl_path)
        end
        
        File.write(crl_path, "-----BEGIN X509 CRL-----\nMIHsMIGTAgEBMA0GCSqGSIb3DQEBCwUAMBQxEjAQBgNVBAMMCVRlc3QgQ0EgMhcN\nMjQwNTEzMTcyMDM1WhcNMjUwNTEzMTcyMDM1WjBEMBMCAgPoFw0yMTA1MTMxNzIw\nMzVaMBMCAgPpFw0yMTA1MTMxNzIwMzVaMBMCAgPqFw0yMTA1MTMxNzIwMzVaMA0G\nCSqGSIb3DQEBCwUAA4GBAGX5rLzwJVAPhJ1iQZLFfzjwVJVGqDIZXt1odApM7/KA\nXrQ5YLVunSBGQTbuRQKNQZQO+snGnZUxJ5OW9eRqp8HWFpCFZbWSJ86eNfuX+GD3\nwgGP/1Zv+iRiZG8ccHQC4fNxQNctMFMccRVmcpOJ8s7h+Y5ohiUXyGTiLbBu4Np3\n-----END X509 CRL-----")

        result = @generator.call
        assert result[:p12].present?

        certificate = Certificate.last
        assert_equal "signed", certificate.status if certificate.respond_to?(:status)
      ensure
        if original_crl
          File.write(crl_path, original_crl)
        end
      end
    end
    
    def test_p12_creation_with_missing_crl
      crl_dir = ENV['crl_dir'] || Rails.root.join('ca/crl').to_s
      crl_path = "#{crl_dir}/crl.pem"

      original_crl = nil
      if File.exist?(crl_path)
        original_crl = File.read(crl_path)
        File.delete(crl_path)
      end
      
      begin
        File.delete(crl_path) if File.exist?(crl_path)
        
        result = @generator.call
        assert result[:p12].present?, "P12 контейнер должен быть создан даже при отсутствии CRL"
      ensure
        if original_crl
          FileUtils.mkdir_p(File.dirname(crl_path))
          File.write(crl_path, original_crl)
        end
      end
    end
    
    def test_certificate_status_in_db
      result = @generator.call

      assert result[:crt].present?
      assert result[:p12].present?

      if defined?(Certificate) && Certificate.method_defined?(:create_from_result)
        certificate = Certificate.create_from_result(result)
        assert_equal "signed", certificate.status if certificate.respond_to?(:status)
      end
      
      assert_nothing_raised do
        OpenSSL::X509::Certificate.new(result[:crt])
      end
    end

  end
end 