require 'test_helper'

class ReppV1RegistrarNotificationsTest < ActionDispatch::IntegrationTest
  def setup
    @user = users(:api_bestnames)
    token = Base64.encode64("#{@user.username}:#{@user.plain_text_password}")
    token = "Basic #{token}"

    @auth_headers = { 'Authorization' => token }
  end

  def test_gets_latest_unread_poll_message
    notification = @user.registrar.notifications.where(read: false).order(created_at: :desc).first
    get "/repp/v1/registrar/notifications", headers: @auth_headers
    json = JSON.parse(response.body, symbolize_names: true)

    assert_response :ok
    assert_equal 1000, json[:code]
    assert_equal 'Command completed successfully', json[:message]
    assert_equal notification.text, json[:data][:text]
  end

  def test_can_read_specific_notification_by_id
    notification = @user.registrar.notifications.order(created_at: :desc).second

    get "/repp/v1/registrar/notifications/#{notification.id}", headers: @auth_headers
    json = JSON.parse(response.body, symbolize_names: true)

    assert_response :ok
    assert_equal 1000, json[:code]
    assert_equal 'Command completed successfully', json[:message]
    assert_equal notification.text, json[:data][:text]
  end

  def test_can_mark_notification_as_read
    @auth_headers['Content-Type'] = 'application/json'
    notification = @user.registrar.notifications.where(read: false).order(created_at: :desc).first

    payload = { notification: { read: true} }
    put "/repp/v1/registrar/notifications/#{notification.id}", headers: @auth_headers, params: payload.to_json
    json = JSON.parse(response.body, symbolize_names: true)
    notification.reload

    assert_response :ok
    assert_equal 1000, json[:code]
    assert_equal 'Command completed successfully', json[:message]
    assert_equal notification.id, json[:data][:notification_id]
    assert_equal notification.read, json[:data][:read]
  end
end
