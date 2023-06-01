require 'test_helper'

class ReppV1ApiUsersListTest < ActionDispatch::IntegrationTest
  def setup
    @user = users(:api_bestnames)
    token = Base64.encode64("#{@user.username}:#{@user.plain_text_password}")
    token = "Basic #{token}"

    @auth_headers = { 'Authorization' => token }

    adapter = ENV['shunter_default_adapter'].constantize.new
    adapter&.clear!
  end

  def test_returns_api_users
    get repp_v1_api_users_url, headers: @auth_headers
    assert_response :success

    response_json = JSON.parse(response.body, symbolize_names: true)
    assert_equal @user.registrar.api_users.count, response_json[:data][:count]
    assert_equal @user.registrar.api_users.count, response_json[:data][:users].length
    assert response_json[:data][:users][0].is_a? Hash
  end

  def test_returns_error_response_if_throttled
    ENV['shunter_default_threshold'] = '1'
    ENV['shunter_enabled'] = 'true'

    get repp_v1_api_users_path, headers: @auth_headers
    get repp_v1_api_users_path, headers: @auth_headers
    json = JSON.parse(response.body, symbolize_names: true)

    assert_response :bad_request
    assert_equal json[:code], 2502
    assert response.body.include?(Shunter.default_error_message)
    ENV['shunter_default_threshold'] = '10000'
    ENV['shunter_enabled'] = 'false'
  end
end