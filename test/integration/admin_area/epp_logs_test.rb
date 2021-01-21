# admin_epp_logs_path
require 'test_helper'
require 'application_system_test_case'

class AdminEppLogsIntegrationTest < ApplicationSystemTestCase
    setup do
        sign_in users(:admin)
    end

    def test_helper_test
        request_xml = <<-XML
        <?xml version="1.0" encoding="UTF-8" standalone="no"?>
        <epp xmlns="https://epp.tld.ee/schema/epp-ee-1.0.xsd">
          <hello/>
        </epp>
      XML
  
      get epp_hello_path, params: { frame: request_xml },
          headers: { 'HTTP_COOKIE' => 'session=non-existent' }
    end

    def test_visit_epp_logs_page
        visit admin_epp_logs_path
        assert_text 'EPP log'
    end

    def test_show_epp_log_page
        visit admin_epp_logs_path
        test_helper_test
        visit admin_epp_logs_path
        puts find(:xpath, "//table").native
        find(:xpath, "//tbody/tr/td/a", match: :first).click
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