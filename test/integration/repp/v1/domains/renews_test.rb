require 'test_helper'

class ReppV1DomainsRenewsTest < ActionDispatch::IntegrationTest
  def setup
    @user = users(:api_bestnames)
    @domain = domains(:shop)
    token = Base64.encode64("#{@user.username}:#{@user.plain_text_password}")
    token = "Basic #{token}"

    @auth_headers = { 'Authorization' => token }
  end

  def test_domain_can_be_renewed
    original_valid_to = @domain.valid_to
    travel_to Time.zone.parse('2010-07-05')

    @auth_headers['Content-Type'] = 'application/json'
    payload = { renew: { period: 1, period_unit: 'y' } }
    post "/repp/v1/domains/#{@domain.name}/renew", headers: @auth_headers, params: payload.to_json
    json = JSON.parse(response.body, symbolize_names: true)

    assert_response :ok
    assert_equal 1000, json[:code]
    assert_equal 'Command completed successfully', json[:message]

    assert @domain.valid_to, original_valid_to + 1.year
  end

  def test_domain_renew_pricing_error
    original_valid_to = @domain.valid_to
    travel_to Time.zone.parse('2010-07-05')

    @auth_headers['Content-Type'] = 'application/json'
    payload = { renew: { period: 100, period_unit: 'y' } }
    post "/repp/v1/domains/#{@domain.name}/renew", headers: @auth_headers, params: payload.to_json
    json = JSON.parse(response.body, symbolize_names: true)

    assert_response :bad_request
    assert_equal 2104, json[:code]
    assert_equal 'Active price missing for this operation!', json[:message]

    assert @domain.valid_to, original_valid_to
  end
end
