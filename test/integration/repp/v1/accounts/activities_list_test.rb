require 'test_helper'

class ReppV1AccountsActivitiesListTest < ActionDispatch::IntegrationTest
  def setup
    @user = users(:api_bestnames)
    token = Base64.encode64("#{@user.username}:#{@user.plain_text_password}")
    token = "Basic #{token}"

    @auth_headers = { 'Authorization' => token }

    adapter = ENV["shunter_default_adapter"].constantize.new
    adapter&.clear!
  end

  def test_returns_account_activities
    get repp_v1_accounts_path, headers: @auth_headers
    json = JSON.parse(response.body, symbolize_names: true)

    assert_response :ok

    assert_equal @user.registrar.cash_account.activities.count, json[:data][:count]
    assert_equal @user.registrar.cash_account.activities.count, json[:data][:activities].length

    assert json[:data][:activities][0].is_a? Hash
  end

  def test_respects_limit
    get repp_v1_accounts_path(limit: 1), headers: @auth_headers
    json = JSON.parse(response.body, symbolize_names: true)

    assert_response :ok

    assert_equal 1, json[:data][:activities].length
  end

  def test_refunds_and_added_credit_are_credits_while_renewals_are_debits
    account = @user.registrar.cash_account
    types = { AccountActivity::REFUND => 'credit', AccountActivity::ADD_CREDIT => 'credit',
              AccountActivity::RENEW => 'debit' }
    types.each do |type, label|
      activity = account.account_activities.create!(activity_type: type, currency: account.currency,
                                                   sum: label == 'credit' ? 10 : -10,
                                                   description: "Activity label #{type}")
      get repp_v1_accounts_path(q: { description_matches: activity.description }),
          headers: @auth_headers

      assert_response :ok
      json = JSON.parse(response.body, symbolize_names: true)
      assert_equal 1, json[:data][:count]
      assert_equal label, json[:data][:activities].first[:type]
      assert_equal activity.sum.to_s, json[:data][:activities].first[:sum]
      assert_equal activity.new_balance.to_s, json[:data][:activities].first[:balance]
    end
  end

  def test_respects_offset
    offset = 1
    get repp_v1_accounts_path(offset: offset), headers: @auth_headers
    json = JSON.parse(response.body, symbolize_names: true)

    assert_response :ok

    assert_equal (@user.registrar.cash_account.activities.count - offset), json[:data][:activities].length
  end

  def test_returns_account_activities_by_search_query
    search_params = {
      description_matches: '%renew%',
    }
    get repp_v1_accounts_path(q: search_params), headers: @auth_headers
    json = JSON.parse(response.body, symbolize_names: true)

    assert_response :ok

    assert_equal json[:data][:activities].length, 1
    assert json[:data][:activities][0].is_a? Hash
  end

  def test_returns_account_activities_by_sort_query
    activity = account_activities(:renew_cash)
    sort_params = {
      s: 'activity_type asc',
    }
    get repp_v1_accounts_path(q: sort_params), headers: @auth_headers
    json = JSON.parse(response.body, symbolize_names: true)

    assert_response :ok

    assert_equal @user.registrar.cash_account.activities.count, json[:data][:count]
    assert_equal @user.registrar.cash_account.activities.count, json[:data][:activities].length
    assert_equal json[:data][:activities][0][:description], activity.description
  end

  def test_returns_error_response_if_throttled
    ENV["shunter_default_threshold"] = '1'
    ENV["shunter_enabled"] = 'true'

    get repp_v1_accounts_path, headers: @auth_headers
    get repp_v1_accounts_path, headers: @auth_headers
    json = JSON.parse(response.body, symbolize_names: true)

    assert_response :bad_request
    assert_equal json[:code], 2502
    assert response.body.include?(Shunter.default_error_message)
    ENV["shunter_default_threshold"] = '10000'
    ENV["shunter_enabled"] = 'false'
  end
end
