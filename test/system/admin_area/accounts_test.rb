require 'application_system_test_case'

class AdminAccountsSystemTest < ApplicationSystemTestCase
  setup do
    sign_in users(:admin)
  end

  def test_download_accounts
    now = Time.zone.parse('2010-07-05 08:00')
    travel_to now

    get admin_accounts_path(format: :csv)

    assert_response :ok
    assert_equal 'text/csv; charset=utf-8', response.headers['Content-Type']
    assert_equal %(attachment; filename="accounts_#{Time.zone.now.to_formatted_s(:number)}.csv"; filename*=UTF-8''accounts_#{Time.zone.now.to_formatted_s(:number)}.csv),
                 response.headers['Content-Disposition']
    assert_not_empty response.body
  end
end
