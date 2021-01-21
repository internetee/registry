# admin_epp_logs_path
require 'test_helper'
require 'application_system_test_case'

class AdminEppLogsIntegrationTest < ApplicationSystemTestCase
    setup do
        sign_in users(:admin)
    end

    def test_visit_epp_logs_page
        visit admin_epp_logs_path
        assert_text 'EPP log'
    end

    def test_show_epp_log_page
        visit admin_epp_logs_path
        find(:css, ".table > tbody:nth-child(2) > tr:nth-child(1) > td:nth-child(1) > a:nth-child(1)", match: :first).click
        assert_text 'Details'
    end

    def test_dates_sort
        Capybara.exact = true
        visit admin_epp_logs_path

        find(:xpath, "//a[contains(text(), 'Created at')]", match: :first).click
        find(:xpath, "//a[contains(text(), 'Created at')]", match: :first).click

        epp_log_date = find(:xpath, "//table/tbody/tr/td[6]", match: :first).text(:all)
        date_now = Date.today.to_s(:db)

        assert_match /#{date_now}/, epp_log_date
    end
    
end