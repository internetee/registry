require 'test_helper'

class ReppV1WhiteIpsCreateTest < ActionDispatch::IntegrationTest
  def setup
    @user = users(:api_bestnames)
    token = Base64.encode64("#{@user.username}:#{@user.plain_text_password}")
    token = "Basic #{token}"

    @auth_headers = { 'Authorization' => token }

    adapter = ENV['shunter_default_adapter'].constantize.new
    adapter&.clear!
  end

  def test_creates_new_white_ip
    request_body = {
      white_ip: {
        address: '127.1.1.1',
        interfaces: ['API'],
      },
    }

    post '/repp/v1/white_ips', headers: @auth_headers, params: request_body
    json = JSON.parse(response.body, symbolize_names: true)

    assert_response :ok
    assert_equal 1000, json[:code]
    assert_equal 'Command completed successfully', json[:message]

    white_ip = WhiteIp.find(json[:data][:ip][:id])
    assert white_ip.present?

    assert_equal(request_body[:white_ip][:address], white_ip.ipv4)
  end

  def test_validates_ip_max_count
    request_body = {
      white_ip: {
        address: '2001:db8::/120',
        interfaces: ['API'],
      },
    }

    post '/repp/v1/white_ips', headers: @auth_headers, params: request_body
    json = JSON.parse(response.body, symbolize_names: true)

    assert_response :bad_request
    assert json[:message].include? 'IP address limit exceeded'
  end

  def test_returns_error_response_if_throttled
    ENV['shunter_default_threshold'] = '1'
    ENV['shunter_enabled'] = 'true'

    request_body = {
      white_ip: {
        address: '127.0.0.1',
        interfaces: ['API'],
      },
    }

    post '/repp/v1/white_ips', headers: @auth_headers, params: request_body
    post '/repp/v1/white_ips', headers: @auth_headers, params: request_body
    json = JSON.parse(response.body, symbolize_names: true)

    assert_response :bad_request
    assert_equal json[:code], 2502
    assert response.body.include?(Shunter.default_error_message)
    ENV['shunter_default_threshold'] = '10000'
    ENV['shunter_enabled'] = 'false'
  end
end
