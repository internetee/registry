require 'test_helper'
require 'application_system_test_case'

class AdminAreaAccountActivitiesIntegrationTest < ApplicationSystemTestCase
    # /admin/account_activities
    setup do
        sign_in users(:admin)
        @original_default_language = Setting.default_language
    end
    # TODO:
    # Should create some account activities
    
    # def test_show_account_activities_page
    #     visit admin_account_activities_path
    #     assert_text 'Account activities'
    # end

end