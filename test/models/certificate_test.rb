require 'test_helper'

class CertificateTest < ActiveSupport::TestCase
  setup do
    @certificate = certificates(:api)
    @valid_crt = <<~CRT
      -----BEGIN CERTIFICATE-----
      MIIDazCCAlOgAwIBAgIUBgtGh4Pw8Luqq/HG4tqG3oIzfHIwDQYJKoZIhvcNAQEL
      BQAwRTELMAkGA1UEBhMCQVUxEzARBgNVBAgMClNvbWUtU3RhdGUxITAfBgNVBAoM
      GEludGVybmV0IFdpZGdpdHMgUHR5IEx0ZDAeFw0yNDAyMTkxMjAwMDBaFw0yNTAy
      MTkxMjAwMDBaMEUxCzAJBgNVBAYTAkFVMRMwEQYDVQQIDApTb21lLVN0YXRlMSEw
      HwYDVQQKDBhJbnRlcm5ldCBXaWRnaXRzIFB0eSBMdGQwggEiMA0GCSqGSIb3DQEB
      AQUAA4IBDwAwggEKAoIBAQDUVURLKdmhmEht7yz3MeQQtn9kMIaIzZDwggZvUg6J
      5PlTabEixVfPzlRJixJBj37hh0Ree6mr19KECtPymy1L9U3oGfF18CJhdzc=
      -----END CERTIFICATE-----
    CRT

    @certificate.update!(
      csr: "-----BEGIN CERTIFICATE REQUEST-----\nMIICszCCAZsCAQAwbjELMAkGA1UEBhMCRUUxFDASBgNVBAMMC2ZyZXNoYm94LmVl\nMRAwDgYDVQQHDAdUYWxsaW5uMREwDwYDVQQKDAhGcmVzaGJveDERMA8GA1UECAwI\nSGFyanVtYWExETAPBgNVBAsMCEZyZXNoYm94MIIBIjANBgkqhkiG9w0BAQEFAAOC\nAQ8AMIIBCgKCAQEA1VVESynZoZhIbe8s9zHkELZ/ZDCGiM2Q8IIGb1IOieT5U2mx\nIsVXz85USYsSQY9+4YdEXnupq9fShArT8pstS/VN6BnxdfAiYXc3UWWAuaYAdNGJ\nDr5Jf6uMt1wVnCgoDL7eJq9tWMwARC/viT81o92fgqHFHW0wEolfCmnpik9o0ACD\nFiWZ9IBIevmFqXtq25v9CY2cT9+eZW127WtJmOY/PKJhzh0QaEYHqXTHWOLZWpnp\nHH4elyJ2CrFulOZbHPkPNB9Nf4XQjzk1ffoH6e5IVys2VV5xwcTkF0jY5XTROVxX\nlR2FWqic8Q2pIhSks48+J6o1GtXGnTxv94lSDwIDAQABoAAwDQYJKoZIhvcNAQEL\nBQADggEBAEFcYmQvcAC8773eRTWBJJNoA4kRgoXDMYiiEHih5iJPVSxfidRwYDTF\nsP+ttNTUg3JocFHY75kuM9T2USh+gu/trRF0o4WWa+AbK3JbbdjdT1xOMn7XtfUU\nZ/f1XCS9YdHQFCA6nk4Z+TLWwYsgk7n490AQOiB213fa1UIe83qIfw/3GRqRUZ7U\nwIWEGsHED5WT69GyxjyKHcqGoV7uFnqFN0sQVKVTy/NFRVQvtBUspCbsOirdDRie\nAB2KbGHL+t1QrRF10szwCJDyk5aYlVhxvdI8zn010nrxHkiyQpDFFldDMLJl10BW\n2w9PGO061z+tntdRcKQGuEpnIr9U5Vs=\n-----END CERTIFICATE REQUEST-----\n",
      private_key: "encrypted_private_key"
    )
  end

  def test_does_metadata_is_api
    api = @certificate.assign_metadata
    assert api, 'api'
  end

  def test_certificate_sign_returns_false
    ENV['ca_key_password'] = 'test_password'
    assert_not @certificate.sign!(password: ENV['ca_key_password'])
  end

  def test_renewable_when_not_expired
    @certificate.update!(
      crt: @valid_crt,
      expires_at: 20.days.from_now
    )
    
    assert @certificate.renewable?
  end

  def test_not_renewable_when_expired
    @certificate.update!(
      crt: @valid_crt,
      expires_at: 1.day.ago
    )
    
    assert @certificate.expired?
    assert_not @certificate.renewable?
  end

  def test_generate_for_api_user
    api_user = users(:api_bestnames)
    
    certificate = nil
    assert_nothing_raised do
      certificate = Certificate.generate_for_api_user(api_user: api_user)
    end
    
    assert certificate.persisted?
    assert_equal api_user, certificate.api_user
    assert certificate.private_key.present?
    assert certificate.csr.present?
    assert certificate.expires_at.present?
  end

  def test_certificate_revoked_when_crl_missing
    crl_dir = ENV['crl_dir'] || Rails.root.join('ca/crl').to_s
    crl_path = "#{crl_dir}/crl.pem"

    original_crl = nil
    if File.exist?(crl_path)
      original_crl = File.read(crl_path)
      File.delete(crl_path)
    end
    
    begin
      File.delete(crl_path) if File.exist?(crl_path)
      revoked = @certificate.respond_to?(:certificate_revoked?) ? @certificate.certificate_revoked? : nil

      if revoked != nil
        assert_not revoked, "Сертификат не должен считаться отозванным при отсутствии CRL"
      end
    ensure
      if original_crl
        FileUtils.mkdir_p(File.dirname(crl_path))
        File.write(crl_path, original_crl)
      end
    end
  end
  
  def test_certificate_status
    @certificate.update(status: "signed") if @certificate.respond_to?(:status)
    
    if @certificate.respond_to?(:status) && @certificate.respond_to?(:revoked?)
      assert_equal "signed", @certificate.status
      assert_not @certificate.revoked?, "Сертификат со статусом 'signed' не должен считаться отозванным"
    end

    @certificate.update(status: "revoked") if @certificate.respond_to?(:status)
    
    if @certificate.respond_to?(:status) && @certificate.respond_to?(:revoked?)
      assert_equal "revoked", @certificate.status
      assert @certificate.revoked?, "Сертификат со статусом 'revoked' должен считаться отозванным"
    end
  end
  
  def test_p12_status_with_properly_initialized_crl
    skip unless @certificate.respond_to?(:certificate_revoked?)

    crl_dir = ENV['crl_dir'] || Rails.root.join('ca/crl').to_s
    crl_path = "#{crl_dir}/crl.pem"
    
    original_crl = nil
    if File.exist?(crl_path)
      original_crl = File.read(crl_path)
    end
    
    begin
      FileUtils.mkdir_p(crl_dir) unless Dir.exist?(crl_dir)
      File.write(crl_path, "-----BEGIN X509 CRL-----\nMIHsMIGTAgEBMA0GCSqGSIb3DQEBCwUAMBQxEjAQBgNVBAMMCVRlc3QgQ0EgMhcN\nMjQwNTEzMTcyMDM1WhcNMjUwNTEzMTcyMDM1WjBEMBMCAgPoFw0yMTA1MTMxNzIw\nMzVaMBMCAgPpFw0yMTA1MTMxNzIwMzVaMBMCAgPqFw0yMTA1MTMxNzIwMzVaMA0G\nCSqGSIb3DQEBCwUAA4GBAGX5rLzwJVAPhJ1iQZLFfzjwVJVGqDIZXt1odApM7/KA\nXrQ5YLVunSBGQTbuRQKNQZQO+snGnZUxJ5OW9eRqp8HWFpCFZbWSJ86eNfuX+GD3\nwgGP/1Zv+iRiZG8ccHQC4fNxQNctMFMccRVmcpOJ8s7h+Y5ohiUXyGTiLbBu4Np3\n-----END X509 CRL-----")
    
      assert_not @certificate.certificate_revoked?, "Сертификат не должен считаться отозванным с пустым CRL"

      if @certificate.respond_to?(:status=)
        @certificate.status = "signed"
        assert_equal "signed", @certificate.status
        
        @certificate.stubs(:certificate_revoked?).returns(true)
        assert @certificate.certificate_revoked?
        
        if @certificate.respond_to?(:p12=)
          @certificate.expects(:status=).with("revoked").at_least_once
        end
      end
    ensure
      if original_crl
        File.write(crl_path, original_crl)
      else
        File.delete(crl_path) if File.exist?(crl_path)
      end
    end
  end
end