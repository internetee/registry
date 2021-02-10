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
end
