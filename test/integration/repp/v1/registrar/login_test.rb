require 'test_helper'

class ReppV1LoginTest < ActionDispatch::IntegrationTest
  def setup
    @user = users(:api_bestnames)
    token = Base64.encode64("#{@user.username}:#{@user.plain_text_password}")
    token = "Basic #{token}"

    @auth_headers = { 'Authorization' => token }
  end

  def test_valid_login
    get '/repp/v1/registrar/login', headers: @auth_headers
    json = JSON.parse(response.body, symbolize_names: true)

    assert_response :ok
    assert_equal json[:data][:username], @user.username
    assert_equal json[:data][:identity_code], @user.identity_code
  end

  def test_invalid_login
    token = Base64.encode64("#{@user.username}:0066600")
    token = "Basic #{token}"

    auth_headers = { 'Authorization' => token }

    get '/repp/v1/registrar/login', headers: auth_headers
    json = JSON.parse(response.body, symbolize_names: true)

    assert_response :unauthorized
    assert_equal json[:message], 'Invalid authorization information'
  end
end
