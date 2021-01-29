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

    def test_default_url_params
        account_activities(:one).update(sum: "123.00")
        visit admin_root_path
        click_link_or_button 'Settings', match: :first
        find(:xpath, "//ul/li/a[text()='Account activities']").click
        
        assert has_current_path?(admin_account_activities_path(created_after: 'today'))
    end

    def test_download_account_activity
        now = Time.zone.parse('2010-07-05 08:00')
        travel_to now
        account_activities(:one).update(sum: "123.00")
    
        get admin_account_activities_path(format: :csv)
    
        assert_response :ok
        assert_equal "text/csv", response.headers['Content-Type']
        assert_equal %(attachment; filename="account_activities_#{Time.zone.now.to_formatted_s(:number)}.csv"; filename*=UTF-8''account_activities_#{Time.zone.now.to_formatted_s(:number)}.csv),
                     response.headers['Content-Disposition']
        assert_not_empty response.body
    end
end
