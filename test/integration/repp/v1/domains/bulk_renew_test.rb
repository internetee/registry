require 'test_helper'

class ReppV1DomainsBulkRenewTest < ActionDispatch::IntegrationTest
  def setup
    travel_to Time.zone.parse('2010-07-05 10:30')
    @user = users(:api_bestnames)
    token = Base64.encode64("#{@user.username}:#{@user.plain_text_password}")
    token = "Basic #{token}"

    @auth_headers = { 'Authorization' => token }
  end

  def test_renews_domains
    payload = {
      "domains": [
        'shop.test',
        'airport.test',
        'library.test'
      ],
      "renew_period": "1y"
    }

    assert_changes -> { Domain.find_by(name: 'shop.test').valid_to } do
      assert_changes -> { Domain.find_by(name: 'airport.test').valid_to } do
        assert_changes -> { Domain.find_by(name: 'library.test').valid_to } do
          post "/repp/v1/domains/renew/bulk", headers: @auth_headers, params: payload
          json = JSON.parse(response.body, symbolize_names: true)

          assert_response :ok
          assert_equal 1000, json[:code]
          assert_equal 'Command completed successfully', json[:message]
          assert json[:data][:updated_domains].include? 'shop.test'
          assert json[:data][:updated_domains].include? 'airport.test'
          assert json[:data][:updated_domains].include? 'library.test'
        end
      end
    end
  end

  def test_throws_error_when_domain_not_renewable
    payload = {
      "domains": [
        'invalid.test',
      ],
      "renew_period": "1y"
    }
    assert_no_changes -> { Domain.find_by(name: 'invalid.test').valid_to } do
      post "/repp/v1/domains/renew/bulk", headers: @auth_headers, params: payload
      json = JSON.parse(response.body, symbolize_names: true)

      assert_response :bad_request
      assert_equal 2002, json[:code]
      assert_equal 'Domain renew error for invalid.test', json[:message]
    end
  end

  def test_throws_error_when_not_enough_balance
    billing_prices(:renew_one_year).update(price_cents: 99999999)
    payload = {
      "domains": [
        'invalid.test',
      ],
      "renew_period": "1y"
    }

    assert_no_changes -> { Domain.find_by(name: 'invalid.test').valid_to } do
      post "/repp/v1/domains/renew/bulk", headers: @auth_headers, params: payload
      json = JSON.parse(response.body, symbolize_names: true)

      assert_response :bad_request
      assert_equal 2002, json[:code]
      assert_equal 'Not enough funds for renew domains', json[:message]
    end
  end

  def test_throws_error_if_invalid_renew_period
    payload = {
      "domains": [
        'shop.test'
      ],
      "renew_period": "nope"
    }

    post "/repp/v1/domains/renew/bulk", headers: @auth_headers, params: payload
    json = JSON.parse(response.body, symbolize_names: true)

    assert_response :bad_request
    assert_equal 2005, json[:code]
    assert_equal 'Invalid renew period', json[:message]
  end
end
