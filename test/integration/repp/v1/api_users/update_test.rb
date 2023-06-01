require 'test_helper'

class ReppV1ApiUsersUpdateTest < ActionDispatch::IntegrationTest
  def setup
    @user = users(:api_bestnames)
    token = Base64.encode64("#{@user.username}:#{@user.plain_text_password}")
    token = "Basic #{token}"

    @auth_headers = { 'Authorization' => token }

    adapter = ENV['shunter_default_adapter'].constantize.new
    adapter&.clear!
  end

  def test_updates_api_user
    request_body = {
      api_user: {
        active: false,
      },
    }

    put "/repp/v1/api_users/#{@user.id}", headers: @auth_headers, params: request_body
    json = JSON.parse(response.body, symbolize_names: true)

    assert_response :ok
    assert_equal 1000, json[:code]
    assert_equal 'Command completed successfully', json[:message]

    api_user = ApiUser.find(json[:data][:api_user][:id])
    assert_equal api_user.username, @user.username
    refute api_user.active
  end

  def test_can_not_change_identity_code_if_already_exists_per_registrar
    epp_user = users(:api_bestnames_epp)
    request_body = {
      api_user: {
        identity_code: @user.identity_code,
      },
    }

    put "/repp/v1/api_users/#{epp_user.id}", headers: @auth_headers, params: request_body
    json = JSON.parse(response.body, symbolize_names: true)

    assert_response :bad_request
    assert json[:message].include? 'Identity code already exists'
  end

  def test_returns_error_if_password_wrong_format
    request_body = {
      api_user: {
        plain_text_password: '123',
      },
    }

    put "/repp/v1/api_users/#{@user.id}", headers: @auth_headers, params: request_body
    json = JSON.parse(response.body, symbolize_names: true)

    assert_response :bad_request
    assert json[:message].include? 'Password is too short'
  end

  def test_returns_error_response_if_throttled
    ENV['shunter_default_threshold'] = '1'
    ENV['shunter_enabled'] = 'true'

    request_body = {
      api_user: {
        active: true,
      },
    }

    put "/repp/v1/api_users/#{@user.id}", headers: @auth_headers, params: request_body
    put "/repp/v1/api_users/#{@user.id}", headers: @auth_headers, params: request_body
    json = JSON.parse(response.body, symbolize_names: true)

    assert_response :bad_request
    assert_equal json[:code], 2502
    assert response.body.include?(Shunter.default_error_message)
    ENV['shunter_default_threshold'] = '10000'
    ENV['shunter_enabled'] = 'false'
  end
end
