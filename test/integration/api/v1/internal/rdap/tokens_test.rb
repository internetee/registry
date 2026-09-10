require 'test_helper'

class ApiV1InternalRdapTokensTest < ApplicationIntegrationTest
  def setup
    ENV['rdap_internal_api_shared_key'] = 'test-rdap-key'
    ENV['rdap_internal_api_allowed_ips'] = '127.0.0.1,::1'
    @header = { 'Authorization' => 'Basic test-rdap-key' }
  end

  def teardown
    ENV.delete('rdap_internal_api_shared_key')
    ENV.delete('rdap_internal_api_allowed_ips')
    super
  end

  # ---- create -------------------------------------------------------------

  def test_create_persists_and_returns_the_token
    assert_difference 'RdapApiToken.count', 1 do
      post '/api/v1/internal/rdap/tokens',
           params: { token_hash: 'digest-fresh', subject: 'EE38001085718',
                     token_class: 'machine', label: 'deploy-bot',
                     expires_at: 90.days.from_now.utc.iso8601 },
           headers: @header
    end
    json = JSON.parse(response.body, symbolize_names: true)

    assert_response :created
    assert_equal 'digest-fresh', json[:token_hash]
    assert_equal 'EE38001085718', json[:subject]
    assert_equal 'machine', json[:token_class]
    assert_equal 'deploy-bot', json[:label]
    assert json[:expires_at].present?
    assert_nil json[:revoked_at]
  end

  def test_create_rejects_invalid_class
    assert_no_difference 'RdapApiToken.count' do
      post '/api/v1/internal/rdap/tokens',
           params: { token_hash: 'digest-bad', subject: 'EE38001085718',
                     token_class: 'root', expires_at: 1.day.from_now.utc.iso8601 },
           headers: @header
    end
    assert_response :unprocessable_entity
  end

  # ---- active (find by hash) ---------------------------------------------

  def test_active_returns_active_token
    token = rdap_api_tokens(:session_active)
    get '/api/v1/internal/rdap/tokens/active',
        params: { token_hash: token.token_hash }, headers: @header
    json = JSON.parse(response.body, symbolize_names: true)

    assert_response :ok
    assert_equal token.subject, json[:subject]
    assert_equal 'session', json[:token_class]
  end

  def test_active_revoked_is_404
    assert_no_active(rdap_api_tokens(:revoked).token_hash)
  end

  def test_active_expired_is_404
    assert_no_active(rdap_api_tokens(:expired).token_hash)
  end

  def test_active_unknown_is_404
    assert_no_active('nope')
  end

  # ---- index (list for subject) ------------------------------------------

  def test_index_lists_only_the_subjects_tokens
    get '/api/v1/internal/rdap/tokens',
        params: { subject: 'EE38001085718' }, headers: @header
    json = JSON.parse(response.body, symbolize_names: true)

    assert_response :ok
    subjects = json.map { |t| t[:subject] }.uniq
    assert_equal %w[EE38001085718], subjects
    assert_not_includes json.map { |t| t[:token_hash] }, rdap_api_tokens(:other_subject_active).token_hash
  end

  # ---- revoke -------------------------------------------------------------

  def test_revoke_makes_token_inactive
    token = rdap_api_tokens(:session_active)
    post '/api/v1/internal/rdap/tokens/revoke',
         params: { token_hash: token.token_hash }, headers: @header

    assert_response :no_content
    assert_not_nil token.reload.revoked_at
    assert_no_active(token.token_hash)
  end

  def test_revoke_unknown_is_idempotent_204
    post '/api/v1/internal/rdap/tokens/revoke',
         params: { token_hash: 'ghost' }, headers: @header
    assert_response :no_content
  end

  # ---- revoke_all ---------------------------------------------------------

  def test_revoke_all_kills_every_active_token_for_subject
    post '/api/v1/internal/rdap/tokens/revoke_all',
         params: { subject: 'EE38001085718' }, headers: @header
    json = JSON.parse(response.body, symbolize_names: true)

    assert_response :ok
    # Revokes every NOT-yet-revoked token for the subject (the kill-all filter is
    # revoked_at IS NULL) — session_active + machine_active + the expired-but-not-
    # revoked one; the already-revoked fixture is left untouched. Matches the RDAP
    # mock semantics (revoked_at.nil? is the only filter).
    assert_equal 3, json[:revoked_count]
    assert_no_active(rdap_api_tokens(:session_active).token_hash)
    assert_no_active(rdap_api_tokens(:machine_active).token_hash)
    # A different subject's token is untouched.
    assert_nil rdap_api_tokens(:other_subject_active).reload.revoked_at
  end

  # ---- touch --------------------------------------------------------------

  def test_touch_sets_last_used_and_keeps_expiry
    token = rdap_api_tokens(:machine_active)
    original_expiry = token.expires_at
    post '/api/v1/internal/rdap/tokens/touch',
         params: { token_hash: token.token_hash }, headers: @header

    assert_response :no_content
    token.reload
    assert_not_nil token.last_used_at
    assert_equal original_expiry.to_i, token.expires_at.to_i
  end

  def test_touch_unknown_is_204
    post '/api/v1/internal/rdap/tokens/touch',
         params: { token_hash: 'ghost' }, headers: @header
    assert_response :no_content
  end

  # ---- auth ---------------------------------------------------------------

  def test_requires_authentication
    get '/api/v1/internal/rdap/tokens/active', params: { token_hash: 'x' }
    assert_response :unauthorized
  end

  private

  def assert_no_active(token_hash)
    get '/api/v1/internal/rdap/tokens/active',
        params: { token_hash: token_hash }, headers: @header
    json = JSON.parse(response.body, symbolize_names: true)
    assert_response :not_found
    assert_equal 'No active token', json[:message]
  end
end
