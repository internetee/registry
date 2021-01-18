require 'test_helper'
require 'application_system_test_case'

class AdminAreaCertificatesIntegrationTest < JavaScriptApplicationSystemTestCase

    # admin_api_user_certificates
    # /admin/api_users/:api_user_id/
    # /admin/api_users/:api_user_id/certificates

    setup do
        WebMock.allow_net_connect!
        sign_in users(:admin)

        @apiuser = users(:api_bestnames)
        @certificate = certificates(:api)
        # @certificate.update!(csr: "-----BEGIN CERTIFICATE REQUEST-----
        # MIICszCCAZsCAQAwbjELMAkGA1UEBhMCRUUxFDASBgNVBAMMC2ZyZXNoYm94LmVl
        # MRAwDgYDVQQHDAdUYWxsaW5uMREwDwYDVQQKDAhGcmVzaGJveDERMA8GA1UECAwI
        # SGFyanVtYWExETAPBgNVBAsMCEZyZXNoYm94MIIBIjANBgkqhkiG9w0BAQEFAAOC
        # AQ8AMIIBCgKCAQEA1VVESynZoZhIbe8s9zHkELZ/ZDCGiM2Q8IIGb1IOieT5U2mx
        # IsVXz85USYsSQY9+4YdEXnupq9fShArT8pstS/VN6BnxdfAiYXc3UWWAuaYAdNGJ
        # Dr5Jf6uMt1wVnCgoDL7eJq9tWMwARC/viT81o92fgqHFHW0wEolfCmnpik9o0ACD
        # FiWZ9IBIevmFqXtq25v9CY2cT9+eZW127WtJmOY/PKJhzh0QaEYHqXTHWOLZWpnp
        # HH4elyJ2CrFulOZbHPkPNB9Nf4XQjzk1ffoH6e5IVys2VV5xwcTkF0jY5XTROVxX
        # lR2FWqic8Q2pIhSks48+J6o1GtXGnTxv94lSDwIDAQABoAAwDQYJKoZIhvcNAQEL
        # BQADggEBAEFcYmQvcAC8773eRTWBJJNoA4kRgoXDMYiiEHih5iJPVSxfidRwYDTF
        # sP+ttNTUg3JocFHY75kuM9T2USh+gu/trRF0o4WWa+AbK3JbbdjdT1xOMn7XtfUU
        # Z/f1XCS9YdHQFCA6nk4Z+TLWwYsgk7n490AQOiB213fa1UIe83qIfw/3GRqRUZ7U
        # wIWEGsHED5WT69GyxjyKHcqGoV7uFnqFN0sQVKVTy/NFRVQvtBUspCbsOirdDRie
        # AB2KbGHL+t1QrRF10szwCJDyk5aYlVhxvdI8zn010nrxHkiyQpDFFldDMLJl10BW
        # 2w9PGO061z+tntdRcKQGuEpnIr9U5Vs=
        # -----END CERTIFICATE REQUEST----\n")
    end

    # Helpers
    def show_certificate_info
        visit admin_api_user_certificate_path(api_user_id: @apiuser.id, id: @certificate.id)
        assert_text 'Certificates'
    end

    # Tests 
    def test_show_certificate_info
        show_certificate_info
    end

    def test_destroy_certificate
        show_certificate_info
        find(:xpath, "//a[text()='Delete']").click

        page.driver.browser.switch_to.alert.accept

        assert_text 'Record deleted'        
    end

    # TODO
    # Should be display "Revoke this certificate" button
    
    # def test_revoke_certificate
    #     show_certificate_info

    #     element = find(:xpath, "//body/div[2]").native.attribute('outerHTML')
    #     puts element

    #     # find(:xpath, "/html/body/div[2]/div[5]/div/div/div[1]/div[2]/a[2]").click

    #     # assert_text 'Record deleted'
    # end

end