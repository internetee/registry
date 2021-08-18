require 'test_helper'
require 'application_system_test_case'

class AdminAreaReppLogsIntegrationTest < ApplicationSystemTestCase
  setup do
    sign_in users(:admin)
  end

  def test_repp_logs_page
    visit admin_repp_logs_path
    assert_text 'REPP log'
  end

  def test_show_repp_log_page
    visit admin_repp_logs_path
    get repp_v1_contacts_path
    visit admin_repp_logs_path

    find(:xpath, "//tbody/tr/td/a", match: :first).click

    assert_text 'REPP log'
  end

  def test_download_repp_logs
    now = Time.zone.parse('2010-07-05 08:00')
    travel_to now

    get admin_repp_logs_path(format: :csv)

    assert_response :ok
    assert_equal 'text/csv; charset=utf-8', response.headers['Content-Type']
    assert_equal %(attachment; filename="repp_logs_#{Time.zone.now.to_formatted_s(:number)}.csv"; filename*=UTF-8''repp_logs_#{Time.zone.now.to_formatted_s(:number)}.csv),
                 response.headers['Content-Disposition']
    assert_not_empty response.body
  end
end
