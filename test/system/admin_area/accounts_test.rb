require 'application_system_test_case'

class AdminAccountsSystemTest < ApplicationSystemTestCase
  setup do
    sign_in users(:admin)
    @account = registrars(:bestnames).cash_account
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

  def test_change_account_balance
    visit edit_admin_account_path(@account)
    assert_button 'Save'
    assert_field 'Balance'
    fill_in 'Balance', with: '234'
    click_on 'Save'

    assert_text 'Account has been successfully updated'
    assert_text '234'
  end

  def test_download_accounts_list_as_csv
    travel_to Time.zone.parse('2010-07-05 10:30')

    get admin_accounts_path(format: :csv)

    assert_response :ok
    assert_equal 'text/csv; charset=utf-8', response.headers['Content-Type']
    assert_equal %(attachment; filename="accounts_#{Time.zone.now.to_formatted_s(:number)}.csv"; filename*=UTF-8''accounts_#{Time.zone.now.to_formatted_s(:number)}.csv),
                 response.headers['Content-Disposition']
    assert_equal file_fixture('accounts.csv').read, response.body
  end
end
