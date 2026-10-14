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

    expected = [{ name: 'Good Names', y: 2 },
                { name: @user.registrar.name, y: 4, sliced: true, selected: true }]
    assert_equal expected.sort_by { |entry| entry[:name] },
                 json[:data].sort_by { |entry| entry[:name] }
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
    assert_equal prev_date, json[:data][:prev_data][:name]
    assert_equal [['Best Names', 0], ['Good Names', 3]],
                 json[:data][:prev_data][:domains].sort_by(&:first)
    assert_equal [['Best Names', 0.0], ['Good Names', 42.9]],
                 json[:data][:prev_data][:market_share].sort_by(&:first)
    assert_equal @today, json[:data][:data][:name]
    assert_equal [['Best Names', 4], ['Good Names', 2]],
                 json[:data][:data][:domains].sort_by(&:first)
    assert_equal [['Best Names', 40.0], ['Good Names', 20.0]],
                 json[:data][:data][:market_share].sort_by(&:first)
  end
end
