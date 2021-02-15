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

  def test_can_query_balance_with_details
    started_from = "2020-01-01"
    end_to = DateTime.current.to_date.to_s(:db)

    get "/repp/v1/accounts/balance?detailed=true&from=#{started_from}&until=#{end_to}", headers: @auth_headers
    json = JSON.parse(response.body, symbolize_names: true)

    assert_response :ok
    assert_equal 1000, json[:code]
    assert_equal 'Command completed successfully', json[:message]
    assert_equal @registrar.registrar.cash_account.balance.to_s, json[:data][:balance]
    assert_equal @registrar.registrar.cash_account.currency, json[:data][:currency]
    assert_equal @registrar.registrar.cash_account.account_activities[0].created_at, json[:data][:transactions][0][:created_at]
    assert_equal @registrar.registrar.cash_account.account_activities[0].description, json[:data][:transactions][0][:description]
    assert_equal @registrar.registrar.cash_account.account_activities[0].activity_type, json[:data][:transactions][0][:action]
    assert_equal @registrar.registrar.cash_account.account_activities[0].sum.to_s, json[:data][:transactions][0][:price]
    assert_equal @registrar.registrar.cash_account.account_activities[0].new_balance.to_s, json[:data][:transactions][0][:new_balance]

    json[:data][:transaction].map do |trans|
        assert trans[:created_at].to_date.to_s(:db) >= started_from
        assert trans[:created_at].to_date.to_s(:db) >= end_to
    end

  end
end
