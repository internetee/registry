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

    # domains counts are unchanged: the spec-13 test_registrar fixtures are excluded by
    # serialize_growth_rate_result. calculate_market_share, however, divides by the total across
    # ALL registrars (test ones included), so the spec-13 domains enlarge the denominator and
    # lower each shown share. There are now 4 spec-13 domains (mytenure/capdomain +
    # orphan/partial, all created 2020-01-01, so present at both dates):
    #   prev  (2023-11): Good 3 / (3 + 0 + 4 spec13) = 42.9 %
    #   today (07.26):   Good 2 / (2 + 4 + 4 spec13) = 20.0 %, Best 4 / 10 = 40.0 %
    assert_equal json[:data], prev_data: { name: prev_date,
                                           domains: [['Good Names', 3], ['Best Names', 0]],
                                           market_share: [['Good Names', 42.9], ['Best Names', 0.0]] },
                              data: { name: @today,
                                      domains: [['Good Names', 2], ['Best Names', 4]],
                                      market_share: [['Good Names', 20.0], ['Best Names', 40.0]] }
  end
end
