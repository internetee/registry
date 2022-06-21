require 'test_helper'

class ReppV1RegistrarAuthTaraCallbackTest < ActionDispatch::IntegrationTest
  def setup
    @user = users(:api_bestnames)
    username = nil
    password = nil
    token = Base64.encode64("#{username}:#{password}")
    token = "Basic #{token}"

    @auth_headers = { 'Authorization' => token }
  end

  def test_validates_user_from_omniauth_params
    request_body = {
      auth: {
        uid: 'EE1234',
      },
    }

    post '/repp/v1/registrar/auth/tara_callback', headers: @auth_headers, params: request_body
    json = JSON.parse(response.body, symbolize_names: true)

    assert_response :ok
    assert_equal 1000, json[:code]
    assert_equal 'Command completed successfully', json[:message]

    user_token = Base64.urlsafe_encode64("#{@user.username}:#{@user.plain_text_password}")
    assert_equal json[:data][:username], @user.username
    assert_equal json[:data][:token], user_token
  end

  def test_invalidates_user_with_wrong_omniauth_params
    request_body = {
      auth: {
        uid: '33333',
      },
    }

    post '/repp/v1/registrar/auth/tara_callback', headers: @auth_headers, params: request_body
    json = JSON.parse(response.body, symbolize_names: true)

    assert_response :unauthorized
    assert_equal 'No such user', json[:message]
  end
end