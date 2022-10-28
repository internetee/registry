require 'test_helper'

class ReppV1AccountsUpdateDetailsTest < ActionDispatch::IntegrationTest
  def setup
    @user = users(:api_bestnames)
    token = Base64.encode64("#{@user.username}:#{@user.plain_text_password}")
    token = "Basic #{token}"

    @auth_headers = { 'Authorization' => token }

    adapter = ENV["shunter_default_adapter"].constantize.new
    adapter&.clear!
  end

  def test_updates_details
    request_body =  {
      account: {
        billing_email: 'donaldtrump@yandex.ru',
        iban: 'GB331111111111111111',
      },
    }

    put '/repp/v1/accounts', headers: @auth_headers, params: request_body
    json = JSON.parse(response.body, symbolize_names: true)

    assert_response :ok
    assert_equal 1000, json[:code]
    assert_equal 'Your account has been updated', json[:message]

    assert_equal(request_body[:account][:billing_email], @user.registrar.billing_email)
    assert_equal(request_body[:account][:iban], @user.registrar.iban)
  end

  def test_returns_error_response_if_throttled
    ENV["shunter_default_threshold"] = '1'
    ENV["shunter_enabled"] = 'true'

    request_body =  {
      account: {
        billing_email: 'donaldtrump@yandex.ru',
        iban: 'GB331111111111111111',
      },
    }

    put '/repp/v1/accounts', headers: @auth_headers, params: request_body
    put '/repp/v1/accounts', headers: @auth_headers, params: request_body
    json = JSON.parse(response.body, symbolize_names: true)

    assert_response :bad_request
    assert_equal json[:code], 2502
    assert response.body.include?(Shunter.default_error_message)
    ENV["shunter_default_threshold"] = '10000'
    ENV["shunter_enabled"] = 'false'
  end
end
