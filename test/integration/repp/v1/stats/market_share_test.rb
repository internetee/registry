require 'test_helper'

class ReppV1StatsMarketShareTest < ActionDispatch::IntegrationTest
  def setup
    @user = users(:api_bestnames)
    token = Base64.encode64("#{@user.username}:#{@user.plain_text_password}")
    token = "Basic #{token}"

    @auth_headers = { 'Authorization' => token }
    @today = Time.zone.today.strftime('%m.%y')
  end

  def test_shows_market_share_distribution_data
    get '/repp/v1/stats/market_share_distribution', headers: @auth_headers,
                                                    params: { q: { end_date: @today } }
    json = JSON.parse(response.body, symbolize_names: true)

    assert_response :ok
    assert_equal 1000, json[:code]
    assert_equal 'Command completed successfully', json[:message]

    assert json[:data].is_a? Array
    assert json[:data][0].is_a? Hash
    assert_equal json[:data][0][:name], 'Good Names'
    assert_nil json[:data][0][:selected]
  end

  def test_shows_market_share_growth_rate_data
    prev_date = Time.zone.today.last_month.strftime('%m.%y')
    get '/repp/v1/stats/market_share_growth_rate', headers: @auth_headers,
                                                   params: { q: { end_date: @today,
                                                                  compare_to_end_date: prev_date } }
    json = JSON.parse(response.body, symbolize_names: true)

    assert_response :ok
    assert_equal 1000, json[:code]
    assert_equal 'Command completed successfully', json[:message]

    data = json[:data]
    assert data[:data].is_a? Hash
    assert data[:prev_data].is_a? Hash
    assert_equal data[:data][:name], @today
    assert data[:data][:domains].is_a? Array
  end
end