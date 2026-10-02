require 'test_helper'

class ReppV1DomainsCancelPendingUpdateTest < ActionDispatch::IntegrationTest
  def setup
    @user = users(:api_bestnames)
    @domain = domains(:shop)
    token = Base64.encode64("#{@user.username}:#{@user.plain_text_password}")
    @auth_headers = { 'Authorization' => "Basic #{token}" }
    Setting.request_confirmation_on_registrant_change_enabled = true
  end

  def test_cancels_pending_registrant_change
    request_registrant_change

    json = cancel_pending_update

    assert_response :ok
    assert_equal 1000, json[:code]
    assert_equal @domain.name, json[:data][:domain][:name]
    refute_includes @domain.statuses, DomainStatus::PENDING_UPDATE
    assert_empty @domain.pending_json
    assert_nil @domain.registrant_verification_token
    assert_nil @domain.registrant_verification_asked_at
  end

  def test_keeps_current_registrant_on_cancel
    old_registrant = @domain.registrant
    request_registrant_change

    cancel_pending_update

    assert_equal old_registrant, @domain.registrant
  end

  def test_notifies_both_registrants_on_cancel
    request_registrant_change
    new_registrant_email = @domain.new_registrant_email
    registrant_email = @domain.registrant.email
    ActionMailer::Base.deliveries.clear

    perform_enqueued_jobs { cancel_pending_update }

    email = ActionMailer::Base.deliveries.last
    assert_includes email.to, new_registrant_email
    assert_includes email.to, registrant_email
  end

  def test_returns_error_when_domain_has_no_pending_update
    refute_includes @domain.statuses, DomainStatus::PENDING_UPDATE

    json = cancel_pending_update

    assert_response :bad_request
    assert_equal 2304, json[:code]
  end

  def test_does_not_cancel_pending_update_of_another_registrar
    request_registrant_change
    other_user = users(:api_goodnames)
    token = Base64.encode64("#{other_user.username}:#{other_user.plain_text_password}")
    @auth_headers = { 'Authorization' => "Basic #{token}" }

    json = cancel_pending_update

    assert_response :not_found
    assert_equal 2303, json[:code]
    assert_includes @domain.statuses, DomainStatus::PENDING_UPDATE
  end

  private

  def request_registrant_change
    new_registrant = contacts(:william)
    refute_equal new_registrant, @domain.registrant

    put "/repp/v1/domains/#{@domain.name}",
        headers: json_headers,
        params: { domain: { registrant: { code: new_registrant.code } } }.to_json

    @domain.reload
    assert_includes @domain.statuses, DomainStatus::PENDING_UPDATE
  end

  def cancel_pending_update
    delete "/repp/v1/domains/#{@domain.name}/pending_update", headers: json_headers

    @domain.reload
    JSON.parse(response.body, symbolize_names: true)
  end

  def json_headers
    @auth_headers.merge('Content-Type' => 'application/json')
  end
end
