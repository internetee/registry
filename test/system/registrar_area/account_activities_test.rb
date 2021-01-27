require 'application_system_test_case'

class RegistrarAccountActivitiesTest < ApplicationSystemTestCase
  setup do
    @registrar = registrars(:bestnames)
    sign_in users(:api_bestnames)
  end

  def test_show_account_activity_page
    account_activities(:one).update(sum: "123.00")
    visit registrar_account_activities_path
    assert_text 'Account activity'
  end

  def test_download_account_activity
    now = Time.zone.parse('2010-07-05 08:00')
    travel_to now
    account_activities(:one).update(sum: "123.00")

    get registrar_account_activities_path(format: :csv)

    assert_response :ok
    assert_equal "text/csv", response.headers['Content-Type']
    assert_equal %(attachment; filename="account_activities_#{Time.zone.now.to_formatted_s(:number)}.csv"; filename*=UTF-8''account_activities_#{Time.zone.now.to_formatted_s(:number)}.csv),
                 response.headers['Content-Disposition']
    assert_not_empty response.body
  end
end