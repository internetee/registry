require 'test_helper'

class ReppV1RegistrarAuthCheckInfoTest < ActionDispatch::IntegrationTest
  def setup
    @user = users(:api_bestnames)
    token = Base64.encode64("#{@user.username}:#{@user.plain_text_password}")
    token = "Basic #{token}"

    @auth_headers = { 'Authorization' => token }
  end

  def test_returns_valid_user_auth_values
    get '/repp/v1/registrar/auth', headers: @auth_headers
    json = JSON.parse(response.body, symbolize_names: true)

    assert_response :ok
    assert_equal 1000, json[:code]
    assert_equal 'Command completed successfully', json[:message]

    assert_equal json[:data][:username], @user.username
    assert json[:data][:roles].include? 'super'
    assert_equal json[:data][:registrar_name], 'Best Names'
    assert json[:data][:abilities].is_a? Hash
  end

  def test_invalid_user_login
    token = Base64.encode64("#{@user.username}:0066600")
    token = "Basic #{token}"

    auth_headers = { 'Authorization' => token }

    get '/repp/v1/registrar/auth', headers: auth_headers
    json = JSON.parse(response.body, symbolize_names: true)

    assert_response :unauthorized
    assert_equal json[:message], 'Invalid authorization information'
  end
end