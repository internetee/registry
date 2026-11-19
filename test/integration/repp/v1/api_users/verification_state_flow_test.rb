require 'test_helper'

class ReppV1ApiUsersVerificationStateFlowTest < ActionDispatch::IntegrationTest
  def setup
    @api_user = users(:api_bestnames)
    @api_user.update_columns(
      active: true,
      subject: 'EE1234',
      verified_at: Time.zone.parse('2024-01-01 12:00:00')
    )
    @api_user_headers = auth_headers_for(@api_user)

    @approver = ApiUser.create!(
      username: 'verification_approver',
      plain_text_password: 'testtest',
      registrar: @api_user.registrar,
      roles: ['super'],
      active: true,
      verified_at: Time.zone.now
    )
    @approver_headers = auth_headers_for(@approver)

    adapter = ENV['shunter_default_adapter'].constantize.new
    adapter&.clear!
  end

  def test_subject_change_revokes_api_user_access_on_next_request
    put "/repp/v1/api_users/#{@api_user.id}",
        headers: @api_user_headers,
        params: { api_user: { subject: 'EE9999' } }

    assert_response :ok

    @api_user.reload
    assert_nil @api_user.verified_at

    get '/repp/v1/registrar/auth', headers: @api_user_headers
    json = JSON.parse(response.body, symbolize_names: true)

    assert_response :unauthorized
    assert_equal I18n.t('registrar.authorization.identity_not_verified'), json[:message]
    assert_equal false, json[:data][:eligible_for_sign_in]
  end

  def test_registrar_approval_verifies_user_regardless_of_previous_login_state
    @api_user.update_columns(
      verified_at: nil,
      verification_pending_at: Time.zone.now,
      verification_snapshot: { 'sub' => 'EE5555' }
    )

    post "/repp/v1/api_users/approve_verification/#{@api_user.id}", headers: @approver_headers
    assert_response :ok

    @api_user.reload
    assert @api_user.verified_at.present?
    assert_nil @api_user.verification_pending_at
    assert_equal 'EE5555', @api_user.subject

    get '/repp/v1/registrar/auth', headers: @api_user_headers
    assert_response :ok
  end

  def test_failed_approval_returns_reason_and_is_logged_as_failed_verification
    @api_user.update_columns(
      verified_at: nil,
      verification_pending_at: Time.zone.now,
      verification_snapshot: { 'sub' => 'EE5555' }
    )
    @approver.update_columns(subject: 'EE5555')

    post "/repp/v1/api_users/approve_verification/#{@api_user.id}", headers: @approver_headers
    json = JSON.parse(response.body, symbolize_names: true)

    assert_response :bad_request
    assert_includes json[:message], @approver.username
    assert json[:data][:verification_failed]
    assert_equal 'subject_taken_by_user', json[:data][:reason]
    assert_equal @api_user.username, json[:data][:api_user][:username]
    assert_equal 'EE5555', json[:data][:api_user][:subject]

    log = ApiLog::ReppLog.failed_identity_verifications.order(:id).last
    assert log.failed_identity_verification?
    assert_equal @api_user.username, log.identity_verification_failure[:username]
    assert_includes log.identity_verification_failure[:message], @approver.username
  end

  def test_approval_with_invalid_user_data_returns_bad_request_instead_of_server_error
    @api_user.update_columns(
      verified_at: nil,
      verification_pending_at: Time.zone.now,
      verification_snapshot: { 'sub' => 'EE5555' },
      plain_text_password: '123'
    )

    post "/repp/v1/api_users/approve_verification/#{@api_user.id}", headers: @approver_headers
    json = JSON.parse(response.body, symbolize_names: true)

    assert_response :bad_request
    assert_equal 'update_failed', json[:data][:reason]
    assert_match(/Password is too short/, json[:message])
    assert_nil @api_user.reload.verified_at
  end

  private

  def auth_headers_for(api_user)
    token = Base64.encode64("#{api_user.username}:#{api_user.plain_text_password}")
    { 'Authorization' => "Basic #{token}" }
  end
end
