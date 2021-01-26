require 'test_helper'
require 'application_system_test_case'

class AdminAreaWhiteIpsIntegrationTest < JavaScriptApplicationSystemTestCase

    setup do
        WebMock.allow_net_connect!
        sign_in users(:admin)

        @domain = domains(:hospital)

        @new_registrant = contacts(:jack)
        @user = users(:api_bestnames)

        @domain.update!(statuses: [DomainStatus::PENDING_UPDATE],
        registrant_verification_asked_at: Time.zone.now - 1.day,
        registrant_verification_token: @token)
    end

    def test_visit_page
        pending_json = { new_registrant_id: @new_registrant.id,
      new_registrant_name: @new_registrant.name,
      new_registrant_email: @new_registrant.email,
      current_user_id: @user.id }

    @domain.update(pending_json: pending_json)
    @domain.reload

        visit edit_admin_domain_path(id: @domain.id)

        puts find(:xpath, "//body").native.attribute('outerHTML')
    end
end