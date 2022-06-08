require 'test_helper'

class ReppV1AccountUpdateAutoReloadBalanceTest < ActionDispatch::IntegrationTest
  def setup
    @user = users(:api_bestnames)
    token = Base64.encode64("#{@user.username}:#{@user.plain_text_password}")
    token = "Basic #{token}"

    @auth_headers = { 'Authorization' => token }
  end

  def test_updates_auto_reload_balance
    amount = 100
    threshold = 10
    request_body = {
      type: {
        amount: amount,
        threshold: threshold,
      },
    }

    assert_nil @user.registrar.settings['balance_auto_reload']

    post '/repp/v1/account/update_auto_reload_balance', headers: @auth_headers,
                                                        params: request_body
    json = JSON.parse(response.body, symbolize_names: true)
    assert_response :ok
    assert_equal 1000, json[:code]
    assert_equal 'Balance Auto-Reload setting has been updated', json[:message]

    @user.registrar.reload

    assert_equal amount, @user.registrar.settings['balance_auto_reload']['type']['amount']
    assert_equal threshold, @user.registrar.settings['balance_auto_reload']['type']['threshold']
  end

  def test_returns_error_if_type_has_wrong_attributes
    min_deposit = 10
    request_body = {
      type: {
        amount: 5,
        threshold: -1,
      },
    }
    Setting.minimum_deposit = min_deposit

    post '/repp/v1/account/update_auto_reload_balance', headers: @auth_headers,
                                                        params: request_body
    json = JSON.parse(response.body, symbolize_names: true)

    assert_response :bad_request
    amount_error = "Amount must be greater than or equal to #{min_deposit.to_f}"
    threshold = 'Threshold must be greater than or equal to 0'
    assert_equal "#{amount_error}, #{threshold}", json[:message]
  end

  def test_disables_auto_reload_balance
    get '/repp/v1/account/disable_auto_reload_balance', headers: @auth_headers
    json = JSON.parse(response.body, symbolize_names: true)

    assert_response :ok
    assert_equal 1000, json[:code]
    assert_equal 'Balance Auto-Reload setting has been disabled', json[:message]

    @user.registrar.reload

    assert_nil @user.registrar.settings['balance_auto_reload']
  end
end