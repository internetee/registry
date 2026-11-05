require 'test_helper'

class ReppV1DomainsPendingNotificationTest < ActionDispatch::IntegrationTest
  def setup
    @user = users(:api_bestnames)
    @domain = domains(:shop)
    token = Base64.encode64("#{@user.username}:#{@user.plain_text_password}")
    @auth_headers = { 'Authorization' => "Basic #{token}", 'Content-Type' => 'application/json' }
    Setting.request_confirmation_on_registrant_change_enabled = true
  end

  def test_show_has_no_pending_without_pending_operation
    get "/repp/v1/domains/#{@domain.name}", headers: @auth_headers

    assert_nil JSON.parse(response.body, symbolize_names: true)[:data][:domain][:pending]
  end

  def test_logs_sent_emails_and_shows_them_in_pending
    perform_enqueued_jobs { request_registrant_change }
    travel 2.minutes
    perform_enqueued_jobs

    pending = show_pending
    assert pending[:requested_at].present?
    assert_equal [DomainPendingNotification::REGISTRANT_CHANGE_CONFIRMATION,
                  DomainPendingNotification::REGISTRANT_CHANGE_NOTICE].sort,
                 pending[:notifications].map { |n| n[:kind] }.sort
    assert_includes pending[:notifications].flat_map { |n| n[:recipients] },
                    @domain.registrant.email
  end

  def test_resends_registrant_change_confirmation
    request_registrant_change
    travel 2.minutes
    perform_enqueued_jobs
    ActionMailer::Base.deliveries.clear

    perform_enqueued_jobs do
      post "/repp/v1/domains/#{@domain.name}/pending_notification", headers: @auth_headers
    end

    assert_response :ok
    assert_equal 1, ActionMailer::Base.deliveries.size
    assert_equal [@domain.registrant.email], ActionMailer::Base.deliveries.last.to
    assert_equal 3, show_pending[:notifications].size
  end

  def test_resends_delete_confirmation
    @domain.update!(statuses: [DomainStatus::PENDING_DELETE_CONFIRMATION])
    @domain.registrant_verification_asked!('<frame/>', @user.id)
    @domain.save!

    perform_enqueued_jobs do
      post "/repp/v1/domains/#{@domain.name}/pending_notification", headers: @auth_headers
    end

    assert_response :ok
    assert_equal [DomainPendingNotification::DELETE_CONFIRMATION],
                 show_pending[:notifications].map { |n| n[:kind] }
  end

  def test_list_filters_domains_with_pending_operation
    request_registrant_change

    get '/repp/v1/domains', headers: @auth_headers, params: { details: true, q: { with_pending_operation: '1' } }
    names = JSON.parse(response.body, symbolize_names: true)[:data][:domains].map { |d| d[:name] }

    assert_equal [@domain.name], names
  end

  def test_returns_error_without_pending_operation
    post "/repp/v1/domains/#{@domain.name}/pending_notification", headers: @auth_headers

    assert_response :bad_request
    assert_equal 2304, JSON.parse(response.body, symbolize_names: true)[:code]
  end

  def test_does_not_resend_for_another_registrar
    request_registrant_change
    other = users(:api_goodnames)
    token = Base64.encode64("#{other.username}:#{other.plain_text_password}")
    headers = { 'Authorization' => "Basic #{token}", 'Content-Type' => 'application/json' }

    post "/repp/v1/domains/#{@domain.name}/pending_notification", headers: headers

    assert_response :not_found
  end

  private

  def request_registrant_change
    put "/repp/v1/domains/#{@domain.name}", headers: @auth_headers,
        params: { domain: { registrant: { code: contacts(:william).code } } }.to_json
    @domain.reload
    assert_includes @domain.statuses, DomainStatus::PENDING_UPDATE
  end

  def show_pending
    get "/repp/v1/domains/#{@domain.name}", headers: @auth_headers
    JSON.parse(response.body, symbolize_names: true)[:data][:domain][:pending]
  end
end
