require 'test_helper'

class AdminAreaAccountsIntegrationTest < ActionDispatch::IntegrationTest
  include Devise::Test::IntegrationHelpers

  setup do
    sign_in users(:admin)
    @account = accounts(:cash)
  end

  def test_index_page_accessible
    get admin_accounts_path
    assert_response :success
    assert_includes response.body, 'Accounts'
  end

  def test_updates_account_balance_and_creates_activity
    new_balance = @account.balance + 50

    assert_difference 'AccountActivity.count', +1 do
      patch admin_account_path(@account), params: {
        account: { balance: new_balance },
        description: 'Balance adjustment by admin'
      }
    end

    assert_redirected_to admin_accounts_path
    follow_redirect!
    assert_response :success

    @account.reload
    assert_equal new_balance, @account.balance
  end

  def test_invalid_balance_shows_error_and_does_not_create_activity
    assert_no_difference 'AccountActivity.count' do
      patch admin_account_path(@account), params: {
        account: { balance: 'invalid' },
        description: 'Should fail'
      }
    end

    assert_response :success 
    assert_includes response.body, I18n.t('invalid_balance')

    @account.reload
    assert_equal 100, @account.balance
  end
end 
