require 'test_helper'

class ReppV1RegistrarSummaryTest < ActionDispatch::IntegrationTest
  def setup
    @user = users(:api_bestnames)
    token = Base64.encode64("#{@user.username}:#{@user.plain_text_password}")
    token = "Basic #{token}"

    @auth_headers = { 'Authorization' => token }
  end

  def test_checks_user_summary_info
    get '/repp/v1/registrar/summary', headers: @auth_headers
    json = JSON.parse(response.body, symbolize_names: true)

    assert_response :ok
    assert_equal 1000, json[:code]
    assert_equal 'Command completed successfully', json[:message]

    assert_equal json[:data][:username], @user.username
    assert_equal json[:data][:registrar_name], 'Best Names'
    assert_equal json[:data][:domains], @user.registrar.domains.count
    assert_equal json[:data][:contacts], @user.registrar.contacts.count
    assert json[:data][:notification].is_a? Hash
    assert_equal json[:data][:notifications_count], @user.unread_notifications.count
  end

  def test_checks_limited_user_summary_info
    @user.update(roles: ['billing'])
    get '/repp/v1/registrar/summary', headers: @auth_headers
    json = JSON.parse(response.body, symbolize_names: true)

    assert_response :ok
    assert_equal 1000, json[:code]
    assert_equal 'Command completed successfully', json[:message]

    assert_equal json[:data][:username], @user.username
    assert_equal json[:data][:registrar_name], 'Best Names'
    assert_nil json[:data][:notification]
    assert_nil json[:data][:notifications_count]
  end
end