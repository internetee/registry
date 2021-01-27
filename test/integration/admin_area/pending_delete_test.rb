require 'test_helper'
require 'application_system_test_case'

class AdminAreaPendingDeleteIntegrationTest < JavaScriptApplicationSystemTestCase

    setup do
        WebMock.allow_net_connect!
        sign_in users(:admin)

        @domain = domains(:shop)
        @token = '123456'

        @domain.update!(statuses: [DomainStatus::PENDING_DELETE_CONFIRMATION],
        registrant_verification_asked_at: Time.zone.now - 1.day,
        registrant_verification_token: @token)
    end

    def test_accept_pending_delete
        visit edit_admin_domain_path(id: @domain.id)

        click_on 'Accept'
        page.driver.browser.switch_to.alert.accept

        assert_text 'Pending was successfully applied.'
    end

    def test_accept_pending_delete_no_success
        @domain.update!(statuses: [DomainStatus::PENDING_DELETE_CONFIRMATION],
        registrant_verification_asked_at: Time.zone.now - 1.day,
        registrant_verification_token: nil)

        visit edit_admin_domain_path(id: @domain.id)

        click_on 'Accept'
        page.driver.browser.switch_to.alert.accept

        assert_text 'Not success'
    end

    def test_reject_panding_delete
        visit edit_admin_domain_path(id: @domain.id)

        click_on 'Reject'
        page.driver.browser.switch_to.alert.accept

        assert_text 'Pending was successfully removed.'
    end

    def test_accept_pending_delete_no_success
        @domain.update!(statuses: [DomainStatus::PENDING_DELETE_CONFIRMATION],
        registrant_verification_asked_at: Time.zone.now - 1.day,
        registrant_verification_token: nil)

        visit edit_admin_domain_path(id: @domain.id)

        click_on 'Reject'
        page.driver.browser.switch_to.alert.accept
        
        assert_text 'Not success'
    end
end