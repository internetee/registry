require 'test_helper'

class CertificateTest < ActiveSupport::TestCase
  setup do
    @certificate = certificates(:api)
    @certificate.update!(csr: "-----BEGIN CERTIFICATE REQUEST-----\nMIICszCCAZsCAQAwbjELMAkGA1UEBhMCRUUxFDASBgNVBAMMC2ZyZXNoYm94LmVl\nMRAwDgYDVQQHDAdUYWxsaW5uMREwDwYDVQQKDAhGcmVzaGJveDERMA8GA1UECAwI\nSGFyanVtYWExETAPBgNVBAsMCEZyZXNoYm94MIIBIjANBgkqhkiG9w0BAQEFAAOC\nAQ8AMIIBCgKCAQEA1VVESynZoZhIbe8s9zHkELZ/ZDCGiM2Q8IIGb1IOieT5U2mx\nIsVXz85USYsSQY9+4YdEXnupq9fShArT8pstS/VN6BnxdfAiYXc3UWWAuaYAdNGJ\nDr5Jf6uMt1wVnCgoDL7eJq9tWMwARC/viT81o92fgqHFHW0wEolfCmnpik9o0ACD\nFiWZ9IBIevmFqXtq25v9CY2cT9+eZW127WtJmOY/PKJhzh0QaEYHqXTHWOLZWpnp\nHH4elyJ2CrFulOZbHPkPNB9Nf4XQjzk1ffoH6e5IVys2VV5xwcTkF0jY5XTROVxX\nlR2FWqic8Q2pIhSks48+J6o1GtXGnTxv94lSDwIDAQABoAAwDQYJKoZIhvcNAQEL\nBQADggEBAEFcYmQvcAC8773eRTWBJJNoA4kRgoXDMYiiEHih5iJPVSxfidRwYDTF\nsP+ttNTUg3JocFHY75kuM9T2USh+gu/trRF0o4WWa+AbK3JbbdjdT1xOMn7XtfUU\nZ/f1XCS9YdHQFCA6nk4Z+TLWwYsgk7n490AQOiB213fa1UIe83qIfw/3GRqRUZ7U\nwIWEGsHED5WT69GyxjyKHcqGoV7uFnqFN0sQVKVTy/NFRVQvtBUspCbsOirdDRie\nAB2KbGHL+t1QrRF10szwCJDyk5aYlVhxvdI8zn010nrxHkiyQpDFFldDMLJl10BW\n2w9PGO061z+tntdRcKQGuEpnIr9U5Vs=\n-----END CERTIFICATE REQUEST-----\n")
  end

  def test_certificate_sign_returns_false
    assert_not @certificate.sign!(password: ENV['ca_key_password']), 'false'
  end

  # Revocation tests
  def test_revoke_with_valid_password
    assert @certificate.revoke!(password: ENV['ca_key_password'])
    assert @certificate.revoked?
    assert_not_nil @certificate.revoked_at
    assert_equal Certificate::REVOCATION_REASONS[:unspecified], @certificate.revoked_reason
  end

  def test_revoke_with_invalid_password
    assert_not @certificate.revoke!(password: 'wrong_password')
    assert_not @certificate.revoked?
    assert_nil @certificate.revoked_at
    assert_nil @certificate.revoked_reason
  end

  def test_revoke_updates_certificate_status
    assert_equal Certificate::SIGNED, @certificate.status
    @certificate.revoke!(password: ENV['ca_key_password'])
    assert_equal Certificate::REVOKED, @certificate.status
  end

  def test_revokable_for_different_interfaces
    @certificate.update!(interface: Certificate::REGISTRAR)
    assert @certificate.revokable?

    @certificate.update!(interface: Certificate::API)
    assert_not @certificate.revokable?

    @certificate.update!(interface: Certificate::REGISTRAR, crt: nil)
    assert_not @certificate.revokable?
  end

  def test_csr_common_name_must_match_username
    api_user = @certificate.api_user
    
    new_cert = Certificate.new(
      api_user: api_user,
      csr: @certificate.csr
    )
    api_user.update!(username: 'different_username')
    
    new_cert.send(:validate_csr_parameters)
    
    assert_includes new_cert.errors.full_messages, I18n.t(:csr_common_name_must_match_username)
  end
  
  def test_csr_country_validation
    api_user = @certificate.api_user
    csr_content = @certificate.csr
    
    new_cert = Certificate.new(
      api_user: api_user,
      csr: csr_content
    )
    api_user.registrar.update!(address_country_code: 'EE', vat_rate: 22)
    
    new_cert.send(:validate_csr_parameters)
    
    assert_not_includes new_cert.errors.full_messages, I18n.t(:csr_country_must_match_registrar_country)
    
    new_cert.errors.clear
    api_user.registrar.update!(address_country_code: 'US', vat_rate: nil)
    new_cert.send(:validate_csr_parameters)
    
    assert_includes new_cert.errors.full_messages, I18n.t(:csr_country_must_match_registrar_country)
  end

  def test_validation_in_controller_context
    api_user = @certificate.api_user
    api_user.update!(username: 'different_username')
    
    cert = Certificate.new(
      api_user: api_user,
      csr: @certificate.csr
    )
    
    Rails.env.stub :test?, false do
      assert_not cert.save
      assert_includes cert.errors.full_messages, I18n.t(:csr_common_name_must_match_username)
    end
    
    assert cert.save(validate: false)
  end
end
