require 'test_helper'

class ReppV1ContactsCheckTest < ActionDispatch::IntegrationTest
  def setup
    @user = users(:api_bestnames)
    token = Base64.encode64("#{@user.username}:#{@user.plain_text_password}")
    token = "Basic #{token}"

    @auth_headers = { 'Authorization' => token }

    adapter = ENV["shunter_default_adapter"].constantize.new
    adapter&.clear!
  end

  def test_code_based_check_returns_true_for_available_contact
    get '/repp/v1/contacts/check/nonexistant:code', headers: @auth_headers
    json = JSON.parse(response.body, symbolize_names: true)

    assert_response :ok
    assert_equal 'nonexistant:code', json[:data][:contact][:code]
    assert_equal true, json[:data][:contact][:available]
  end

  def test_code_based_check_returns_true_for_available_contact
    contact = contacts(:jack)
    get "/repp/v1/contacts/check/#{contact.code}", headers: @auth_headers
    json = JSON.parse(response.body, symbolize_names: true)

    assert_response :ok
    assert_equal contact.code, json[:data][:contact][:code]
    assert_equal false, json[:data][:contact][:available]
  end

  def test_returns_error_response_if_throttled
    ENV["shunter_default_threshold"] = '1'
    ENV["shunter_enabled"] = 'true'

    contact = contacts(:jack)
    get "/repp/v1/contacts/check/#{contact.code}", headers: @auth_headers
    get "/repp/v1/contacts/check/#{contact.code}", headers: @auth_headers
    json = JSON.parse(response.body, symbolize_names: true)

    assert_response :bad_request
    assert_equal json[:code], 2502
    assert response.body.include?(Shunter.default_error_message)
    ENV["shunter_default_threshold"] = '10000'
    ENV["shunter_enabled"] = 'false'
  end
end
