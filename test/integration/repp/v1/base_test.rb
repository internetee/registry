require 'test_helper'

class ReppV1BaseTest < ActionDispatch::IntegrationTest
  def setup
    @registrar = users(:api_bestnames)
    token = Base64.encode64("#{@registrar.username}:#{@registrar.plain_text_password}")
    token = "Basic #{token}"

    @auth_headers = { 'Authorization' => token }
  end

  def test_unauthorized_user_has_no_access
    get repp_v1_contacts_path
    response_json = JSON.parse(response.body, symbolize_names: true)

    assert_response :unauthorized
    assert_equal 'Invalid authorization information', response_json[:message]

    invalid_token = Base64.encode64("nonexistant:user")
    headers = { 'Authorization' => "Basic #{invalid_token}" }

    get repp_v1_contacts_path, headers: headers
    response_json = JSON.parse(response.body, symbolize_names: true)

    assert_response :unauthorized
    assert_equal 'Invalid authorization information', response_json[:message]
  end

  def test_authenticates_valid_user
    get repp_v1_contacts_path, headers: @auth_headers
    response_json = JSON.parse(response.body, symbolize_names: true)

    assert_response :ok
  end

  def test_processes_invalid_base64_token_format_properly
    token = '??as8d9sf kjsdjh klsdfjjf'
    headers = { 'Authorization' => "Basic #{token}"}
    get repp_v1_contacts_path, headers: headers
    response_json = JSON.parse(response.body, symbolize_names: true)

    assert_response :unauthorized
    assert_equal 'Invalid authorization information', response_json[:message]
  end

  def test_takes_ip_whitelist_into_account
    Setting.api_ip_whitelist_enabled = true
    Setting.registrar_ip_whitelist_enabled = true

    whiteip = white_ips(:one)
    whiteip.update(ipv4: '1.1.1.1')

    get repp_v1_contacts_path, headers: @auth_headers
    response_json = JSON.parse(response.body, symbolize_names: true)

    assert_response :unauthorized
    assert_equal 2202, response_json[:code]
    assert response_json[:message].include? 'Access denied from IP'

    Setting.api_ip_whitelist_enabled = false
    Setting.registrar_ip_whitelist_enabled = false
  end
end
