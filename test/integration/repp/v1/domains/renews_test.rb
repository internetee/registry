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
    domain_spy = Spy.on_instance_method(Epp::Domain, :renew).and_call_through
    renew_spy = Spy.on_instance_method(Domains::BulkRenew::SingleDomainRenew,
                                       :prepare_renewed_expire_time).and_call_through

    @auth_headers['Content-Type'] = 'application/json'
    payload = { renews: { period: 1, period_unit: 'y', exp_date: original_valid_to } }
    post "/repp/v1/domains/#{@domain.name}/renew", headers: @auth_headers, params: payload.to_json
    json = JSON.parse(response.body, symbolize_names: true)

    assert_response :ok
    assert_equal 1000, json[:code]
    assert_equal 'Command completed successfully', json[:message]

    assert @domain.valid_to, original_valid_to + 1.year
    assert domain_spy.has_been_called?
    assert renew_spy.has_been_called?
  end

  def test_domain_renew_pricing_error
    original_valid_to = @domain.valid_to
    travel_to Time.zone.parse('2010-07-05')

    @auth_headers['Content-Type'] = 'application/json'
    payload = { renews: { period: 10, period_unit: 'y', exp_date: original_valid_to } }
    post "/repp/v1/domains/#{@domain.name}/renew", headers: @auth_headers, params: payload.to_json
    json = JSON.parse(response.body, symbolize_names: true)

    assert_response :bad_request
    assert_equal 2104, json[:code]
    assert_equal 'Active price missing for this operation!', json[:message]

    assert @domain.valid_to, original_valid_to
  end

  def test_some_test
    days_to_renew_domain_before_expire = setting_entries(:days_to_renew_domain_before_expire)
    days_to_renew_domain_before_expire.update(value: '1')
    days_to_renew_domain_before_expire.reload

    original_valid_to = @domain.valid_to
    travel_to @domain.valid_to - 3.days

    one_year = billing_prices(:renew_one_year)
    one_year.update(valid_from: @domain.valid_to - 5.days)
    one_year.reload

    @auth_headers['Content-Type'] = 'application/json'
    payload = { renews: { period: 1, period_unit: 'y', exp_date: original_valid_to } }
    post "/repp/v1/domains/#{@domain.name}/renew", headers: @auth_headers, params: payload.to_json
    json = JSON.parse(response.body, symbolize_names: true)

    assert_response :bad_request
    assert_equal 2304, json[:code]
    assert_equal 'Object status prohibits operation', json[:message]
  end
end
