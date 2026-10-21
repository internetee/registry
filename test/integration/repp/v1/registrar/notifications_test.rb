require 'test_helper'

class ReppV1RegistrarNotificationsTest < ActionDispatch::IntegrationTest
  def setup
    @user = users(:api_bestnames)
    token = Base64.encode64("#{@user.username}:#{@user.plain_text_password}")
    token = "Basic #{token}"

    @auth_headers = { 'Authorization' => token }

    adapter = ENV["shunter_default_adapter"].constantize.new
    adapter&.clear!
  end

  def test_all_unreaded_poll_messages
    notification = @user.registrar.notifications.where(read: false).order(created_at: :desc).all
    get "/repp/v1/registrar/notifications/all_notifications", headers: @auth_headers
    json = JSON.parse(response.body, symbolize_names: true)

    assert_response :ok
    assert_equal notification.count, json[:data].count
    assert_equal json[:data].first[:text], notification.first.text
    assert_equal json[:data].last[:text], notification.last.text
  end

  def test_all_notifications_returns_error_response_if_throttled
    ENV["shunter_default_threshold"] = '1'
    ENV["shunter_enabled"] = 'true'

    notification = @user.registrar.notifications.where(read: false).order(created_at: :desc).all
    get "/repp/v1/registrar/notifications/all_notifications", headers: @auth_headers
    get "/repp/v1/registrar/notifications/all_notifications", headers: @auth_headers
    json = JSON.parse(response.body, symbolize_names: true)

    assert_response :bad_request
    assert_equal json[:code], 2502
    assert response.body.include?(Shunter.default_error_message)
    ENV["shunter_default_threshold"] = '10000'
    ENV["shunter_enabled"] = 'false'
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

  def test_index_returns_error_response_if_throttled
    ENV["shunter_default_threshold"] = '1'
    ENV["shunter_enabled"] = 'true'

    notification = @user.registrar.notifications.where(read: false).order(created_at: :desc).first
    get "/repp/v1/registrar/notifications", headers: @auth_headers
    get "/repp/v1/registrar/notifications", headers: @auth_headers
    json = JSON.parse(response.body, symbolize_names: true)

    assert_response :bad_request
    assert_equal json[:code], 2502
    assert response.body.include?(Shunter.default_error_message)
    ENV["shunter_default_threshold"] = '10000'
    ENV["shunter_enabled"] = 'false'
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

  def test_show_returns_error_response_if_throttled
    ENV["shunter_default_threshold"] = '1'
    ENV["shunter_enabled"] = 'true'

    notification = @user.registrar.notifications.order(created_at: :desc).second

    get "/repp/v1/registrar/notifications/#{notification.id}", headers: @auth_headers
    get "/repp/v1/registrar/notifications/#{notification.id}", headers: @auth_headers
    json = JSON.parse(response.body, symbolize_names: true)

    assert_response :bad_request
    assert_equal json[:code], 2502
    assert response.body.include?(Shunter.default_error_message)
    ENV["shunter_default_threshold"] = '10000'
    ENV["shunter_enabled"] = 'false'
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

  def test_queued_funding_warning_keeps_event_after_renewal_in_index_list_and_show
    travel_to Time.zone.local(2027, 3, 5, 12)
    domain = domains(:shop)
    cycle = domain.auto_renewals.create!(
      domain_name: domain.name, registrar: @user.registrar, account: @user.registrar.cash_account,
      state: DomainAutoRenewal::GRACE, original_expire_at: 1.day.ago,
      renewed_expire_at: 1.day.ago.advance(years: 1), cancellation_deadline_at: 14.days.from_now,
      attempts_count: 1, charge_activity: account_activities(:renew_cash)
    )
    notification = @user.registrar.notifications.create!(
      event: 'fundingWarning', text: 'Insufficient funds for automatic renewal',
      attached_obj_type: 'DomainAutoRenewal', attached_obj_id: cycle.id
    )
    expected = { event: 'fundingWarning', domain: domain.name, cycle: cycle.as_protocol_json }

    ['/repp/v1/registrar/notifications',
     '/repp/v1/registrar/notifications/all_notifications',
     "/repp/v1/registrar/notifications/#{notification.id}"].each do |path|
      get path, headers: @auth_headers
      json = JSON.parse(response.body, symbolize_names: true)

      assert_response :ok
      data = json[:data].is_a?(Array) ? json[:data].find { |item| item[:id] == notification.id } : json[:data]
      assert_equal notification.id, data[:id]
      assert_equal expected, data[:attached_obj_data]
    end
  end

  def test_overdue_event_survives_late_success_in_notifications_and_summary
    travel_to Time.zone.local(2027, 3, 5, 12)
    domain = domains(:shop)
    cycle = domain.auto_renewals.create!(
      domain_name: domain.name, registrar: @user.registrar, account: @user.registrar.cash_account,
      original_expire_at: 16.days.ago, cancellation_deadline_at: 1.day.ago,
      overdue_notice_sent_at: Time.zone.now
    )
    notification = @user.registrar.notifications.create!(
      event: 'renewalOverdue', text: 'Automatic renewal overdue',
      attached_obj_type: 'DomainAutoRenewal', attached_obj_id: cycle.id
    )
    [DomainAutoRenewal::AWAITING_FUNDS, DomainAutoRenewal::COMPLETED].each do |state|
      cycle.update!(state: state)
      ['/repp/v1/registrar/notifications',
       '/repp/v1/registrar/notifications/all_notifications',
       "/repp/v1/registrar/notifications/#{notification.id}",
       '/repp/v1/registrar/summary'].each do |path|
        get path, headers: @auth_headers
        json = JSON.parse(response.body, symbolize_names: true)
        assert_response :ok
        data = if json[:data].is_a?(Array)
                 json[:data].find { |item| item[:id] == notification.id }
               elsif path.end_with?('/summary')
                 json[:data][:notification]
               else
                 json[:data]
               end
        assert_equal notification.id, data[:id]
        assert_equal({ event: 'renewalOverdue', domain: domain.name, cycle: cycle.as_protocol_json },
                     data[:attached_obj_data])
      end
    end
  end

  def test_auto_renewal_notification_survives_domain_deletion
    domain = domains(:shop)
    cycle = DomainAutoRenewal.create!(
      domain_name: domain.name, registrar: @user.registrar, account: @user.registrar.cash_account,
      state: DomainAutoRenewal::CANCELLED, original_expire_at: 16.days.ago,
      cancellation_deadline_at: 1.day.ago, attempts_count: 3, domain_id: nil
    )
    notification = @user.registrar.notifications.create!(
      event: 'renewalOverdue', text: 'Automatic renewal overdue',
      attached_obj_type: 'DomainAutoRenewal', attached_obj_id: cycle.id
    )
    get "/repp/v1/registrar/notifications/#{notification.id}", headers: @auth_headers
    json = JSON.parse(response.body, symbolize_names: true)

    assert_response :ok
    assert_equal({ event: 'renewalOverdue', domain: domain.name, cycle: cycle.as_protocol_json },
                 json[:data][:attached_obj_data])
  end
end
