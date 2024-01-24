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

    assert_equal json[:data], [{ name: 'Good Names', y: 2 },
                               { name: @user.registrar.name, y: 4, sliced: true, selected: true }]
  end

  def test_shows_market_share_growth_rate_data
    prev_date = Date.new(2023, 11, 1).strftime('%m.%y')
    get '/repp/v1/stats/market_share_growth_rate', headers: @auth_headers,
                                                   params: { q: { end_date: @today,
                                                                  compare_to_end_date: prev_date } }
    json = JSON.parse(response.body, symbolize_names: true)

    assert_response :ok
    assert_equal 1000, json[:code]
    assert_equal 'Command completed successfully', json[:message]

    assert_equal json[:data], prev_data: { name: prev_date,
                                           domains: [['Good Names', 3], ['Best Names', 0]],
                                           market_share: [['Good Names', 100.0], ['Best Names', 0.0]] },
                              data: { name: @today,
                                      domains: [['Good Names', 2], ['Best Names', 4]],
                                      market_share: [['Good Names', 33.3], ['Best Names', 66.7]] }
  end
end
