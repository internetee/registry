require 'test_helper'

class ReppV1ApiWhiteIpsUpdateTest < ActionDispatch::IntegrationTest
  def setup
    @user = users(:api_bestnames)
    @white_ip = white_ips(:one)
    token = Base64.encode64("#{@user.username}:#{@user.plain_text_password}")
    token = "Basic #{token}"

    @auth_headers = { 'Authorization' => token }

    adapter = ENV['shunter_default_adapter'].constantize.new
    adapter&.clear!
  end

  def test_updates_white_ip
    request_body = {
      white_ip: {
        address: '127.0.0.2',
      },
    }

    put "/repp/v1/white_ips/#{@white_ip.id}", headers: @auth_headers, params: request_body
    json = JSON.parse(response.body, symbolize_names: true)

    assert_response :ok
    assert_equal 1000, json[:code]
    assert_equal 'Command completed successfully', json[:message]

    ip = WhiteIp.find(json[:data][:ip][:id])
    assert_equal ip.ipv4, '127.0.0.2'
    refute ip.committed

    last_email = ActionMailer::Base.deliveries.last
    assert last_email.subject.include?('Whitelisted IP Address Change Notification')
  end

  def test_returns_error_if_ipv4_wrong_format
    request_body = {
      white_ip: {
        address: 'wrongip',
      },
    }

    put "/repp/v1/white_ips/#{@white_ip.id}", headers: @auth_headers, params: request_body
    json = JSON.parse(response.body, symbolize_names: true)

    assert_response :bad_request
    assert json[:message].include? 'Address is invalid'
  end

  def test_returns_error_response_if_throttled
    ENV['shunter_default_threshold'] = '1'
    ENV['shunter_enabled'] = 'true'

    request_body = {
      white_ip: {
        address: '127.0.0.1',
      },
    }

    put "/repp/v1/white_ips/#{@white_ip.id}", headers: @auth_headers, params: request_body
    put "/repp/v1/white_ips/#{@white_ip.id}", headers: @auth_headers, params: request_body
    json = JSON.parse(response.body, symbolize_names: true)

    assert_response :bad_request
    assert_equal json[:code], 2502
    assert response.body.include?(Shunter.default_error_message)
    ENV['shunter_default_threshold'] = '10000'
    ENV['shunter_enabled'] = 'false'
  end
end
