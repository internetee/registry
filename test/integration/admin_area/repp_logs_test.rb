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

  def test_filters_and_marks_failed_identity_verifications
    ApiLog::ReppLog.create!(request_path: '/repp/v1/contacts', request_method: 'GET', response_code: '200')
    ApiLog::ReppLog.create!(
      request_path: '/repp/v1/api_users/approve_verification/1', request_method: 'POST',
      response_code: '400', api_user_name: 'approver',
      response: { message: 'Identity EE1 is already linked to API user bob at this registrar',
                  data: { verification_failed: true,
                          api_user: { username: 'machine_user', identity_code: nil, subject: 'EE1' } } }.to_json
    )

    visit admin_repp_logs_path(failed_verifications: '1')

    assert_text 'Identity verification failed'
    assert_text 'machine_user (EE1)'
    assert_text 'already linked to API user bob'
    assert_no_link '/repp/v1/contacts'
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
