require 'test_helper'

class ReppV1StatsMarketShareTest < ActionDispatch::IntegrationTest
  def setup
    @user = users(:api_bestnames)
    token = Base64.encode64("#{@user.username}:#{@user.plain_text_password}")
    token = "Basic #{token}"

    @auth_headers = { 'Authorization' => token }
  end

  def test_shows_market_share_data
    get '/repp/v1/stats/market_share', headers: @auth_headers
    json = JSON.parse(response.body, symbolize_names: true)

    assert_response :ok
    assert_equal 1000, json[:code]
    assert_equal 'Command completed successfully', json[:message]

    assert json[:data].is_a? Array
    assert json[:data][0].is_a? Hash
    assert_equal json[:data][0][:name], 'Best Names'
    assert json[:data][0][:selected]
  end
end