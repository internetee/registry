require 'test_helper'

class ReppV1ApiWhiteIpsShowTest < ActionDispatch::IntegrationTest
  def setup
    @user = users(:api_bestnames)
    token = Base64.encode64("#{@user.username}:#{@user.plain_text_password}")
    token = "Basic #{token}"

    @auth_headers = { 'Authorization' => token }

    adapter = ENV['shunter_default_adapter'].constantize.new
    adapter&.clear!
  end

  def test_returns_error_when_not_found
    get repp_v1_white_ip_path(id: 'definitelynotexistant'), headers: @auth_headers
    json = JSON.parse(response.body, symbolize_names: true)

    assert_response :not_found
    assert_equal 2303, json[:code]
    assert_equal 'Object does not exist', json[:message]
  end

  def test_shows_existing_white_ip
    white_ip = @user.registrar.white_ips.first

    get repp_v1_white_ip_path(id: white_ip.id), headers: @auth_headers
    json = JSON.parse(response.body, symbolize_names: true)

    assert_response :ok
    assert_equal 1000, json[:code]
    assert_equal 'Command completed successfully', json[:message]

    assert_equal white_ip.id, json[:data][:ip][:id]
    assert_equal WhiteIp::INTERFACES, json[:data][:interfaces]
  end

  def test_returns_error_response_if_throttled
    ENV['shunter_default_threshold'] = '1'
    ENV['shunter_enabled'] = 'true'

    white_ip = @user.registrar.white_ips.first

    get repp_v1_white_ip_path(id: white_ip.id), headers: @auth_headers
    get repp_v1_white_ip_path(id: white_ip.id), headers: @auth_headers
    json = JSON.parse(response.body, symbolize_names: true)

    assert_response :bad_request
    assert_equal json[:code], 2502
    assert response.body.include?(Shunter.default_error_message)
    ENV['shunter_default_threshold'] = '10000'
    ENV['shunter_enabled'] = 'false'
  end
end
