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
      
      generator = CertificateGenerator.new(
        username: "test_user",
        registrar_code: "REG123",
        registrar_name: "Test Registrar"
      )
      
      result = generator.call
      
      assert result[:crt].present?
      assert result[:expires_at] > Time.current
      assert_instance_of String, result[:crt]
      assert_instance_of Time, result[:expires_at]
    end
  end
end 