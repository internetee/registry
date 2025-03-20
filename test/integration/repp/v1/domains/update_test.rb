require 'test_helper'

class ReppV1DomainsUpdateTest < ActionDispatch::IntegrationTest
  def setup
    @user = users(:api_bestnames)
    @domain = domains(:shop)
    token = Base64.encode64("#{@user.username}:#{@user.plain_text_password}")
    token = "Basic #{token}"

    @auth_headers = { 'Authorization' => token }
  end

  def test_updates_transfer_code_for_domain
    @auth_headers['Content-Type'] = 'application/json'
    new_auth_code = 'aisdcbkabcsdnc'

    payload = {
      domain: {
        auth_code: new_auth_code,
      },
    }

    put "/repp/v1/domains/#{@domain.name}", headers: @auth_headers, params: payload.to_json
    @domain.reload
    json = JSON.parse(response.body, symbolize_names: true)
    assert_response :ok
    assert_equal 1000, json[:code]
    assert_equal 'Command completed successfully', json[:message]

    assert new_auth_code, @domain.auth_info
  end

  def test_domain_pending_update_on_registrant_change
    Setting.request_confirmation_on_registrant_change_enabled = true

    @auth_headers['Content-Type'] = 'application/json'
    new_registrant = contacts(:william)
    refute @domain.registrant == new_registrant

    payload = {
      domain: {
        registrant: {
          code: new_registrant.code,
        },
      },
    }

    put "/repp/v1/domains/#{@domain.name}", headers: @auth_headers, params: payload.to_json
    @domain.reload
    json = JSON.parse(response.body, symbolize_names: true)
    assert_response :ok
    assert_equal 1000, json[:code]
    assert_equal 'Command completed successfully', json[:message]

    refute @domain.registrant.code == new_registrant.code
    assert @domain.statuses.include? DomainStatus::PENDING_UPDATE
  end

  def test_replaces_registrant_when_verified
    Setting.request_confirmation_on_registrant_change_enabled = true

    @auth_headers['Content-Type'] = 'application/json'
    new_registrant = contacts(:william)
    refute @domain.registrant == new_registrant
    old_transfer_code = @domain.transfer_code

    payload = {
      domain: {
        registrant: {
          code: new_registrant.code,
          verified: true,
        },
      },
    }

    put "/repp/v1/domains/#{@domain.name}", headers: @auth_headers, params: payload.to_json
    @domain.reload

    json = JSON.parse(response.body, symbolize_names: true)
    assert_response :ok
    assert_equal 1000, json[:code]
    assert_equal 'Command completed successfully', json[:message]

    refute_equal old_transfer_code, @domain.transfer_code
    assert @domain.registrant.code == new_registrant.code
    refute @domain.statuses.include? DomainStatus::PENDING_UPDATE
  end

  def test_adds_epp_error_when_reserved_pw_is_missing_for_disputed_domain
    Dispute.create!(domain_name: @domain.name, password: '1234567890', starts_at: Time.zone.now, expires_at: Time.zone.now + 5.days)

    @auth_headers['Content-Type'] = 'application/json'
    payload = {
      domain: {
        reserved_pw: nil,
      },
    }

    put "/repp/v1/domains/#{@domain.name}", headers: @auth_headers, params: payload.to_json
    @domain.reload
    json = JSON.parse(response.body, symbolize_names: true)
    assert_response :bad_request
    assert_equal 2304, json[:code]
    assert_equal 'Required parameter missing; reservedpw element required for dispute domains', json[:message]
  end

  def test_adds_epp_error_when_reserved_pw_is_invalid_for_disputed_domain
    Dispute.create!(domain_name: @domain.name, password: '1234567890', starts_at: Time.zone.now, expires_at: Time.zone.now + 5.days)

    @auth_headers['Content-Type'] = 'application/json'
    payload = {
      domain: {
        reserved_pw: 'invalid',
      },
    }

    put "/repp/v1/domains/#{@domain.name}", headers: @auth_headers, params: payload.to_json
    @domain.reload
    json = JSON.parse(response.body, symbolize_names: true)
    assert_response :bad_request
    assert_equal 2202, json[:code]
    assert_equal 'Invalid authorization information; invalid reserved>pw value', json[:message]
  end
end
