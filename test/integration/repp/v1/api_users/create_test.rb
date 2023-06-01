require 'test_helper'

class ReppV1ApiUsersCreateTest < ActionDispatch::IntegrationTest
  def setup
    @user = users(:api_bestnames)
    token = Base64.encode64("#{@user.username}:#{@user.plain_text_password}")
    token = "Basic #{token}"

    @auth_headers = { 'Authorization' => token }

    adapter = ENV['shunter_default_adapter'].constantize.new
    adapter&.clear!
  end

  def test_creates_new_api_user
    request_body = {
      api_user: {
        username: 'username',
        plain_text_password: 'password',
        active: true,
        identity_code: '123',
        roles: ['super'],
      },
    }

    post '/repp/v1/api_users', headers: @auth_headers, params: request_body
    json = JSON.parse(response.body, symbolize_names: true)

    assert_response :ok
    assert_equal 1000, json[:code]
    assert_equal 'Command completed successfully', json[:message]

    api_user = ApiUser.find(json[:data][:api_user][:id])
    assert api_user.present?
    assert api_user.active

    assert_equal(request_body[:api_user][:username], api_user.username)
  end

  def test_validates_identity_code_per_registrar
    request_body = {
      api_user: {
        username: 'username',
        plain_text_password: 'password',
        active: true,
        identity_code: @user.identity_code,
        roles: ['super'],
      },
    }

    post '/repp/v1/api_users', headers: @auth_headers, params: request_body
    json = JSON.parse(response.body, symbolize_names: true)

    assert_response :bad_request
    assert json[:message].include? 'Identity code already exists'
  end

  def test_returns_error_response_if_throttled
    ENV['shunter_default_threshold'] = '1'
    ENV['shunter_enabled'] = 'true'

    request_body = {
      api_user: {
        username: 'username',
        plain_text_password: 'password',
        active: true,
        identity_code: '123',
        roles: ['super'],
      },
    }

    post '/repp/v1/api_users', headers: @auth_headers, params: request_body
    post '/repp/v1/api_users', headers: @auth_headers, params: request_body
    json = JSON.parse(response.body, symbolize_names: true)

    assert_response :bad_request
    assert_equal json[:code], 2502
    assert response.body.include?(Shunter.default_error_message)
    ENV['shunter_default_threshold'] = '10000'
    ENV['shunter_enabled'] = 'false'
  end
end
