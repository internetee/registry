require 'test_helper'

class CertificateTest < ActiveSupport::TestCase
  setup do
    @certificate = certificates(:api)
    @certificate.update!(csr: "-----BEGIN CERTIFICATE REQUEST-----\nMIICszCCAZsCAQAwbjELMAkGA1UEBhMCRUUxFDASBgNVBAMMC2ZyZXNoYm94LmVl\nMRAwDgYDVQQHDAdUYWxsaW5uMREwDwYDVQQKDAhGcmVzaGJveDERMA8GA1UECAwI\nSGFyanVtYWExETAPBgNVBAsMCEZyZXNoYm94MIIBIjANBgkqhkiG9w0BAQEFAAOC\nAQ8AMIIBCgKCAQEA1VVESynZoZhIbe8s9zHkELZ/ZDCGiM2Q8IIGb1IOieT5U2mx\nIsVXz85USYsSQY9+4YdEXnupq9fShArT8pstS/VN6BnxdfAiYXc3UWWAuaYAdNGJ\nDr5Jf6uMt1wVnCgoDL7eJq9tWMwARC/viT81o92fgqHFHW0wEolfCmnpik9o0ACD\nFiWZ9IBIevmFqXtq25v9CY2cT9+eZW127WtJmOY/PKJhzh0QaEYHqXTHWOLZWpnp\nHH4elyJ2CrFulOZbHPkPNB9Nf4XQjzk1ffoH6e5IVys2VV5xwcTkF0jY5XTROVxX\nlR2FWqic8Q2pIhSks48+J6o1GtXGnTxv94lSDwIDAQABoAAwDQYJKoZIhvcNAQEL\nBQADggEBAEFcYmQvcAC8773eRTWBJJNoA4kRgoXDMYiiEHih5iJPVSxfidRwYDTF\nsP+ttNTUg3JocFHY75kuM9T2USh+gu/trRF0o4WWa+AbK3JbbdjdT1xOMn7XtfUU\nZ/f1XCS9YdHQFCA6nk4Z+TLWwYsgk7n490AQOiB213fa1UIe83qIfw/3GRqRUZ7U\nwIWEGsHED5WT69GyxjyKHcqGoV7uFnqFN0sQVKVTy/NFRVQvtBUspCbsOirdDRie\nAB2KbGHL+t1QrRF10szwCJDyk5aYlVhxvdI8zn010nrxHkiyQpDFFldDMLJl10BW\n2w9PGO061z+tntdRcKQGuEpnIr9U5Vs=\n-----END CERTIFICATE REQUEST-----\n")
  end

  def test_does_metadata_is_api
    api = @certificate.assign_metadata
    assert api, 'api'
  end

  def test_certificate_sign_returns_false
    assert_not @certificate.sign!, 'false'
  end
end