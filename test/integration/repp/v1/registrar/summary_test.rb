require 'test_helper'

class ReppV1RegistrarSummaryTest < ActionDispatch::IntegrationTest
  def setup
    @user = users(:api_bestnames)
    token = Base64.encode64("#{@user.username}:#{@user.plain_text_password}")
    token = "Basic #{token}"

    @auth_headers = { 'Authorization' => token }

    adapter = ENV["shunter_default_adapter"].constantize.new
    adapter&.clear!
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
    assert_equal json[:data][:balance][:amount].to_f, @user.registrar.cash_account.balance
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

  def test_returns_error_response_if_throttled
    ENV["shunter_default_threshold"] = '1'
    ENV["shunter_enabled"] = 'true'

    get '/repp/v1/registrar/summary', headers: @auth_headers
    get '/repp/v1/registrar/summary', headers: @auth_headers
    json = JSON.parse(response.body, symbolize_names: true)

    assert_response :bad_request
    assert_equal json[:code], 2502
    assert response.body.include?(Shunter.default_error_message)
    ENV["shunter_default_threshold"] = '10000'
    ENV["shunter_enabled"] = 'false'
  end

  def test_handles_contact_update_notification_with_missing_contact
    action = actions(:contact_update)
    action.update!(contact: nil)
    notifications(:complete).update!(
      action: action,
      attached_obj_type: 'ContactUpdateAction',
      attached_obj_id: action.id,
      text: 'Contact update notification'
    )

    get '/repp/v1/registrar/summary', headers: @auth_headers
    json = JSON.parse(response.body, symbolize_names: true)

    assert_response :ok
    assert_equal 1000, json[:code]
    assert_equal [], json[:data][:notification][:attached_obj_data][:contacts]
  end

  def test_auto_renewal_notification_attached_data
    travel_to Time.zone.local(2027, 3, 5, 12)
    domain = domains(:shop)
    cycle = domain.auto_renewals.create!(
      domain_name: domain.name, registrar: @user.registrar, account: @user.registrar.cash_account,
      state: DomainAutoRenewal::AWAITING_FUNDS, failure_reason: DomainAutoRenewal::INSUFFICIENT_FUNDS,
      original_expire_at: 1.day.ago, cancellation_deadline_at: 14.days.from_now, attempts_count: 2
    )
    notification = @user.registrar.notifications.create!(
      event: 'fundingWarning', text: 'Insufficient funds for automatic renewal',
      attached_obj_type: 'DomainAutoRenewal', attached_obj_id: cycle.id
    )

    travel_to Time.zone.now + 1.hour
    cycle.update!(state: DomainAutoRenewal::CANCELLED)
    get '/repp/v1/registrar/summary', headers: @auth_headers
    json = JSON.parse(response.body, symbolize_names: true)

    assert_response :ok
    assert_equal notification.id, json[:data][:notification][:id]
    assert_equal({ event: 'fundingWarning', domain: domain.name, cycle: cycle.as_protocol_json },
                 json[:data][:notification][:attached_obj_data])
  end
end
