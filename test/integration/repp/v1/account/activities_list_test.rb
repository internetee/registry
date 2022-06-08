require 'test_helper'

class ReppV1AccountActivitiesListTest < ActionDispatch::IntegrationTest
  def setup
    @user = users(:api_bestnames)
    token = Base64.encode64("#{@user.username}:#{@user.plain_text_password}")
    token = "Basic #{token}"

    @auth_headers = { 'Authorization' => token }
  end

  def test_returns_account_activities
    get repp_v1_account_path, headers: @auth_headers
    json = JSON.parse(response.body, symbolize_names: true)

    assert_response :ok

    assert_equal @user.registrar.cash_account.activities.count, json[:data][:count]
    assert_equal @user.registrar.cash_account.activities.count, json[:data][:activities].length

    assert json[:data][:activities][0].is_a? Hash
  end

  def test_respects_limit
    get repp_v1_account_path(limit: 1), headers: @auth_headers
    json = JSON.parse(response.body, symbolize_names: true)

    assert_response :ok

    assert_equal 1, json[:data][:activities].length
  end

  def test_respects_offset
    offset = 1
    get repp_v1_account_path(offset: offset), headers: @auth_headers
    json = JSON.parse(response.body, symbolize_names: true)

    assert_response :ok

    assert_equal (@user.registrar.cash_account.activities.count - offset), json[:data][:activities].length
  end

  def test_returns_account_activities_by_search_query
    search_params = {
      description_matches: '%renew%',
    }
    get repp_v1_account_path(q: search_params), headers: @auth_headers
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
    get repp_v1_account_path(q: sort_params), headers: @auth_headers
    json = JSON.parse(response.body, symbolize_names: true)

    assert_response :ok

    assert_equal @user.registrar.cash_account.activities.count, json[:data][:count]
    assert_equal @user.registrar.cash_account.activities.count, json[:data][:activities].length
    assert_equal json[:data][:activities][0][:description], activity.description
  end
end
