require 'test_helper'
require 'application_system_test_case'

class AdminAreaAccountActivitiesIntegrationTest < ApplicationSystemTestCase
    # /admin/account_activities
    setup do
        sign_in users(:admin)
        @original_default_language = Setting.default_language
    end
    
    def test_show_account_activities_page
        account_activities(:one).update(sum: "123.00")
        visit admin_account_activities_path
        assert_text 'Account activities'
    end

    def test_invalid_date_account_activities
        account_activities(:one).update(sum: "123.00")
        account_activities(:one).update(created_at: "0000-12-12")
        visit admin_account_activities_path
        assert_text 'Account activities'

        puts find(:xpath, "//body").native
    end
end