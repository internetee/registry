# admin_registrar_white_ips GET             /admin/registrars/:registrar_id/white_ips(.:format) 

require 'test_helper'
require 'application_system_test_case'

class AdminAreaWhiteIpsIntegrationTest < JavaScriptApplicationSystemTestCase

    setup do
        WebMock.allow_net_connect!
        sign_in users(:admin)

        @registrar = registrars(:bestnames)
        @white_ip = white_ips(:one)
    end

    # Helpers ====================================
    def visit_new_whitelisted_ip_page
        visit new_admin_registrar_white_ip_path(registrar_id: @registrar.id)
        assert_text 'New whitelisted IP'
    end

    def visit_edit_whitelisted_ip_page
        visit edit_admin_registrar_white_ip_path(registrar_id: @registrar.id, id: @white_ip.id)
        assert_text 'Edit white IP'
    end

    def visit_info_whitelisted_ip_page
        visit admin_registrar_white_ip_path(registrar_id: @registrar.id, id: @white_ip.id)
        assert_text 'White IP'
    end

    # Tests =====================================

    def test_visit_new_whitelisted_ip_page
        visit_new_whitelisted_ip_page
    end

    def test_create_new_whitelisted_ip
        visit_new_whitelisted_ip_page
        fill_in 'IPv4', with: "127.0.0.1"
        fill_in 'IPv6', with: "::ffff:192.0.2.1"

        find(:css, "#white_ip_interfaces_api").set(true)
        find(:css, "#white_ip_interfaces_registrar").set(true)

        click_on 'Save'

        assert_text 'Record created'
    end

    def test_failed_to_create_new_whitelisted_ip
        visit_new_whitelisted_ip_page
        fill_in 'IPv4', with: "asdadadad.asd"

        click_on 'Save'

        assert_text 'Failed to create record'
    end

    def test_visit_edit_whitelisted_ip_page
        visit_edit_whitelisted_ip_page
    end

    def test_update_whitelisted_ip
        visit_info_whitelisted_ip_page
        click_on 'Edit'

        fill_in 'IPv4', with: "127.0.0.2"

        find(:css, "#white_ip_interfaces_api").set(false)

        click_on 'Save'

        assert_text 'Record updated'
    end

    def test_failed_to_update_whitelisted_ip
        visit_info_whitelisted_ip_page
        click_on 'Edit'

        fill_in 'IPv4', with: "asdadad#"

        click_on 'Save'

        assert_text 'Failed to update record'
    end

    def test_visit_info_whitelisted_ip_page
        visit_info_whitelisted_ip_page
    end

    def test_delete_whitelisted_ip
        visit_info_whitelisted_ip_page

        click_on 'Delete'

        page.driver.browser.switch_to.alert.accept

        assert_text 'Record deleted'
    end
end