require 'test_helper'

class ReppV1BalanceTest < ActionDispatch::IntegrationTest
  def setup
    travel_to Time.zone.parse('2010-07-05')
    @registrar = users(:api_bestnames)
    token = Base64.encode64("#{@registrar.username}:#{@registrar.plain_text_password}")
    token = "Basic #{token}"

    @auth_headers = { 'Authorization' => token }
  end

  def test_can_query_balance
    get '/repp/v1/account/balance', headers: @auth_headers
    json = JSON.parse(response.body, symbolize_names: true)

    assert_response :ok
    assert_equal 1000, json[:code]
    assert_equal 'Command completed successfully', json[:message]
    assert_equal @registrar.registrar.cash_account.balance.to_s, json[:data][:balance]
    assert_equal @registrar.registrar.cash_account.currency, json[:data][:currency]
  end

  def test_can_query_balance_with_details
    # Create new billable action to get activity
    post "/repp/v1/domains/renew/bulk", headers: @auth_headers, params: { domains: ['shop.test'], renew_period: '1y' }

    started_from = "2010-07-05"
    end_to = DateTime.current.to_date.to_s(:db)

    get "/repp/v1/account/balance?detailed=true", headers: @auth_headers
    json = JSON.parse(response.body, symbolize_names: true)

    assert_response :ok
    assert_equal 1000, json[:code]
    assert_equal 'Command completed successfully', json[:message]
    assert_equal @registrar.registrar.cash_account.balance.to_s, json[:data][:balance]
    assert_equal @registrar.registrar.cash_account.currency, json[:data][:currency]
    entry = json[:data][:transactions].last
    assert_equal @registrar.registrar.cash_account.account_activities.last.created_at, entry[:created_at]
    assert_equal @registrar.registrar.cash_account.account_activities.last.description, entry[:description]
    assert_equal 'debit', entry[:type]
    assert_equal @registrar.registrar.cash_account.account_activities.last.sum.to_s, entry[:sum]
    assert_equal @registrar.registrar.cash_account.account_activities.last.new_balance.to_s, entry[:balance]

    json[:data][:transactions].map do |trans|
      assert trans[:created_at].to_date.to_s(:db) >= started_from
      assert trans[:created_at].to_date.to_s(:db) >= end_to
    end
  end
end
