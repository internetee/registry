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
end