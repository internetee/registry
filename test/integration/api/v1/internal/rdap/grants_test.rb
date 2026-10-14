require 'test_helper'

class ApiV1InternalRdapGrantsTest < ApplicationIntegrationTest
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

  def test_returns_active_grant
    get '/api/v1/internal/rdap/grants/active', params: { subject: 'EE38001085718' },
                                               headers: @header
    json = JSON.parse(response.body, symbolize_names: true)

    assert_response :ok
    assert_equal 'EE38001085718', json[:eeid_subject]
    assert_equal 'active', json[:status]
    assert json[:grant_id].present?
  end

  # Two active grants share EE38001085718; the latest valid_from wins
  # (police_active_newer, category cert, valid_from 1.day.ago).
  # The serializer is a frozen contract: admin-only columns added by spec
  # 09-registry-privileged-admin (full_name, legal_basis_ref, personal_id_code,
  # creator_str/updator_str) MUST NOT surface in the RDAP-facing output.
  def test_serializer_exposes_no_admin_only_or_pii_fields
    # Value chosen so it is NOT a substring of the eeid_subject the serializer
    # legitimately returns (EE38001085718).
    rdap_privilege_grants(:police_active_newer).update!(personal_id_code: '49001010001')

    get '/api/v1/internal/rdap/grants/active', params: { subject: 'EE38001085718' },
                                               headers: @header
    json = JSON.parse(response.body, symbolize_names: true)

    assert_response :ok
    %i[full_name legal_basis_ref personal_id_code creator_str updator_str].each do |field|
      assert_not_includes json.keys, field
    end
    assert_no_match '49001010001', response.body
  end

  def test_multiple_active_returns_latest_valid_from
    get '/api/v1/internal/rdap/grants/active', params: { subject: 'EE38001085718' },
                                               headers: @header
    json = JSON.parse(response.body, symbolize_names: true)

    assert_response :ok
    assert_equal 'cert', json[:privilege_category]
    assert_equal %w[cert], json[:privileges]
    assert_equal rdap_privilege_grants(:police_active_newer).uuid, json[:grant_id]
  end

  def test_revoked_grant_is_not_active
    assert_no_active_grant('EE10001001000')
  end

  def test_suspended_grant_is_not_active
    assert_no_active_grant('EE10001001001')
  end

  def test_expired_grant_is_not_active
    assert_no_active_grant('EE10001001002')
  end

  def test_not_yet_valid_grant_is_not_active
    assert_no_active_grant('EE10001001003')
  end

  def test_unknown_subject_returns_404
    assert_no_active_grant('EE00000000000')
  end

  def test_requires_authentication
    get '/api/v1/internal/rdap/grants/active', params: { subject: 'EE38001085718' }
    assert_response :unauthorized
  end

  def test_touch_sets_last_used_at_and_returns_204
    grant = rdap_privilege_grants(:police_active)
    assert_nil grant.last_used_at

    post "/api/v1/internal/rdap/grants/#{grant.uuid}/touch", headers: @header

    assert_response :no_content
    assert_not_nil grant.reload.last_used_at
  end

  def test_touch_unknown_grant_returns_404
    post '/api/v1/internal/rdap/grants/does-not-exist/touch', headers: @header
    json = JSON.parse(response.body, symbolize_names: true)

    assert_response :not_found
    assert_equal 'Grant not found', json[:message]
  end

  private

  def assert_no_active_grant(subject)
    get '/api/v1/internal/rdap/grants/active', params: { subject: subject },
                                               headers: @header
    json = JSON.parse(response.body, symbolize_names: true)

    assert_response :not_found
    assert_equal 'No active grant', json[:message]
  end
end
