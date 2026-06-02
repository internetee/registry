require 'test_helper'

class ReppV1DomainsUpdateTest < ActionDispatch::IntegrationTest
  def setup
    @user = users(:api_bestnames)
    @domain = domains(:shop)
    token = Base64.encode64("#{@user.username}:#{@user.plain_text_password}")
    @auth_headers = { 'Authorization' => "Basic #{token}" }
  end

  def test_updates_transfer_code_for_domain
    json = update_domain(transfer_code: 'aisdcbkabcsdnc')

    assert_repp_success(json)
    assert_equal 'aisdcbkabcsdnc', @domain.transfer_code
  end

  def test_domain_pending_update_on_registrant_change
    Setting.request_confirmation_on_registrant_change_enabled = true
    new_registrant = contacts(:william)
    refute_equal new_registrant, @domain.registrant

    json = update_domain(registrant: { code: new_registrant.code })

    assert_repp_success(json)
    refute_equal new_registrant.code, @domain.registrant.code
    assert_includes @domain.statuses, DomainStatus::PENDING_UPDATE
  end

  def test_replaces_registrant_when_verified
    Setting.request_confirmation_on_registrant_change_enabled = true
    new_registrant = contacts(:william)
    refute_equal new_registrant, @domain.registrant
    old_transfer_code = @domain.transfer_code

    json = update_domain(registrant: { code: new_registrant.code, verified: true })

    assert_repp_success(json)
    refute_equal old_transfer_code, @domain.transfer_code
    assert_equal new_registrant.code, @domain.registrant.code
    refute_includes @domain.statuses, DomainStatus::PENDING_UPDATE
  end

  def test_adds_epp_error_when_disputed_domain_updated_without_registrant_change
    create_dispute
    old_auth_code = @domain.auth_info

    json = update_domain(auth_code: 'new-auth-code')

    assert_repp_error(
      json,
      http_status: :bad_request,
      code: 2304,
      message: 'Object status prohibits operation; disputed domain update requires registrant change'
    )
    assert_equal old_auth_code, @domain.auth_info
    assert @domain.disputed?
  end

  def test_adds_epp_error_when_reserved_pw_is_missing_for_disputed_registrant_change
    create_dispute
    new_registrant = contacts(:william)

    json = update_domain(registrant: { code: new_registrant.code })

    assert_repp_error(
      json,
      http_status: :bad_request,
      code: 2304,
      message: 'Required parameter missing; reservedpw element required for dispute domains'
    )
    refute_equal new_registrant.code, @domain.registrant.code
    assert @domain.disputed?
  end

  def test_rejects_disputed_domain_update_with_valid_pw_but_no_registrant_change
    dispute = create_dispute
    old_auth_code = @domain.auth_info

    json = update_domain(auth_code: 'new-auth-code', reserved_pw: dispute.password)

    assert_repp_error(
      json,
      http_status: :bad_request,
      code: 2304,
      message: 'Object status prohibits operation; disputed domain update requires registrant change'
    )
    assert_equal old_auth_code, @domain.auth_info
    assert @domain.disputed?
  end

  def test_rejects_disputed_priv_to_org_without_admin_and_keeps_disputed_status
    Setting.request_confirmation_on_registrant_change_enabled = false
    @domain.admin_domain_contacts.destroy_all
    dispute = create_dispute
    org = contacts(:acme_ltd)
    old_registrant = @domain.registrant

    json = update_domain(
      registrant: { code: org.code },
      reserved_pw: dispute.password
    )

    assert_repp_error(
      json,
      http_status: :bad_request,
      code: 2306,
      message: 'Admin contact is required'
    )
    assert_equal old_registrant.code, @domain.registrant.code
    assert @domain.disputed?
  end

  def test_updates_disputed_domain_when_registrant_changed_with_valid_reserved_pw
    dispute = create_dispute
    new_registrant = contacts(:william)
    old_transfer_code = @domain.transfer_code

    json = update_domain(
      registrant: { code: new_registrant.code, verified: true },
      reserved_pw: dispute.password
    )

    assert_response :ok
    assert_equal 1000, json[:code]
    assert_equal new_registrant.code, @domain.registrant.code
    refute_equal old_transfer_code, @domain.transfer_code
    assert_not @domain.disputed?
  end

  def test_adds_epp_error_when_reserved_pw_is_invalid_for_disputed_domain
    create_dispute
    new_registrant = contacts(:william)

    json = update_domain(
      registrant: { code: new_registrant.code },
      reserved_pw: 'invalid'
    )

    assert_repp_error(
      json,
      http_status: :bad_request,
      code: 2202,
      message: 'Invalid authorization information; invalid reserved>pw value'
    )
    refute_equal new_registrant.code, @domain.registrant.code
    assert @domain.disputed?
  end

  def test_rejects_disputed_domain_registrant_and_transfer_code_change_without_reserved_pw
    create_dispute
    new_registrant = contacts(:william)
    old_transfer_code = @domain.transfer_code

    json = update_domain(
      registrant: { code: new_registrant.code },
      transfer_code: 'new-transfer-code'
    )

    assert_repp_error(
      json,
      http_status: :bad_request,
      code: 2304,
      message: 'Required parameter missing; reservedpw element required for dispute domains'
    )
    refute_equal new_registrant.code, @domain.registrant.code
    assert_equal old_transfer_code, @domain.transfer_code
    assert @domain.disputed?
  end

  def test_updates_disputed_domain_when_registrant_and_transfer_code_changed_with_valid_reserved_pw
    dispute = create_dispute
    new_registrant = contacts(:william)
    old_transfer_code = @domain.transfer_code

    json = update_domain(
      registrant: { code: new_registrant.code, verified: true },
      transfer_code: 'new-transfer-code',
      reserved_pw: dispute.password
    )

    assert_response :ok
    assert_equal 1000, json[:code]
    assert_equal new_registrant.code, @domain.registrant.code
    refute_equal old_transfer_code, @domain.transfer_code
    assert_not @domain.disputed?
  end

  private

  def update_domain(domain_params)
    put "/repp/v1/domains/#{@domain.name}",
        headers: json_headers,
        params: { domain: domain_params }.to_json

    @domain.reload
    JSON.parse(response.body, symbolize_names: true)
  end

  def json_headers
    @auth_headers.merge('Content-Type' => 'application/json')
  end

  def create_dispute(password: '1234567890')
    Dispute.create!(
      domain_name: @domain.name,
      password: password,
      starts_at: Time.zone.now,
      expires_at: Time.zone.now + 5.days
    )
  end

  def assert_repp_success(json)
    assert_response :ok
    assert_equal 1000, json[:code]
    assert_equal 'Command completed successfully', json[:message]
  end

  def assert_repp_error(json, http_status:, code:, message:)
    assert_response http_status
    assert_equal code, json[:code]
    assert_equal message, json[:message]
  end
end
