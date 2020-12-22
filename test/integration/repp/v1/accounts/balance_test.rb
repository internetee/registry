require 'test_helper'

class ReppV1BalanceTest < ActionDispatch::IntegrationTest
  def setup
    @registrar = users(:api_bestnames)
    token = Base64.encode64("#{@registrar.username}:#{@registrar.plain_text_password}")
    token = "Basic #{token}"

    @auth_headers = { 'Authorization' => token }
  end

  def test_can_query_balance
    get '/repp/v1/accounts/balance', headers: @auth_headers
    json = JSON.parse(response.body, symbolize_names: true)

    assert_response :ok
    assert_equal 1000, json[:code]
    assert_equal 'Command completed successfully', json[:message]
    assert_equal @registrar.registrar.cash_account.balance.to_s, json[:data][:balance]
    assert_equal @registrar.registrar.cash_account.currency, json[:data][:currency]
  end
end
