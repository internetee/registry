require 'test_helper'

class ReppV1WhiteIpsDeleteTest < ActionDispatch::IntegrationTest
  def setup
    @user = users(:api_bestnames)
    token = Base64.encode64("#{@user.username}:#{@user.plain_text_password}")
    token = "Basic #{token}"

    @auth_headers = { 'Authorization' => token }

    adapter = ENV['shunter_default_adapter'].constantize.new
    adapter&.clear!
  end

  def test_deletes_white_ip
    ip = white_ips(:one)
    delete "/repp/v1/white_ips/#{ip.id}", headers: @auth_headers
    json = JSON.parse(response.body, symbolize_names: true)

    assert_response :ok
    assert_equal 1000, json[:code]
    assert_equal 'Command completed successfully', json[:message]
    refute WhiteIp.exists?(ip.id)

    last_email = ActionMailer::Base.deliveries.last
    assert last_email.subject.include?('Whitelisted IP Address Removal Notification')
  end

  def test_returns_error_response_if_throttled
    ENV['shunter_default_threshold'] = '1'
    ENV['shunter_enabled'] = 'true'

    delete "/repp/v1/white_ips/#{white_ips(:one).id}", headers: @auth_headers
    delete "/repp/v1/white_ips/#{white_ips(:two).id}", headers: @auth_headers
    json = JSON.parse(response.body, symbolize_names: true)

    assert_response :bad_request
    assert_equal json[:code], 2502
    assert response.body.include?(Shunter.default_error_message)
    ENV['shunter_default_threshold'] = '10000'
    ENV['shunter_enabled'] = 'false'
  end
end
