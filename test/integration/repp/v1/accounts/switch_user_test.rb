require 'test_helper'

class ReppV1AccountsSwitchUserTest < ActionDispatch::IntegrationTest
  def setup
    @user = users(:api_bestnames)
    token = Base64.encode64("#{@user.username}:#{@user.plain_text_password}")
    token = "Basic #{token}"

    @auth_headers = { 'Authorization' => token }
  end

  def test_switches_to_linked_api_user
    new_user = users(:api_goodnames)
    new_user.update(identity_code: '1234')
    request_body = {
      account: {
        new_user_id: new_user.id,
      },
    }

    put '/repp/v1/accounts/switch_user', headers: @auth_headers, params: request_body
    json = JSON.parse(response.body, symbolize_names: true)

    assert_response :ok
    assert_equal 1000, json[:code]
    assert_equal "You are now signed in as a user \"#{new_user.username}\"", json[:message]

    user_token = Base64.urlsafe_encode64("#{new_user.username}:#{new_user.plain_text_password}")
    assert_equal json[:data][:token], user_token
    assert_equal json[:data][:registrar][:username], new_user.username
    assert json[:data][:registrar][:roles].include? 'super'
    assert_equal json[:data][:registrar][:registrar_name], 'Good Names'
    assert json[:data][:registrar][:abilities].is_a? Hash
  end

  def test_switches_to_unlinked_api_user
    new_user = users(:api_goodnames)
    new_user.update(identity_code: '4444')
    request_body = {
      account: {
        new_user_id: new_user.id,
      },
    }

    put '/repp/v1/accounts/switch_user', headers: @auth_headers, params: request_body
    json = JSON.parse(response.body, symbolize_names: true)

    assert_response :bad_request
    assert_equal 'Cannot switch to unlinked user', json[:message]
  end
end