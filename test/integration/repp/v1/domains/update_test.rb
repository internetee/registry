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

    assert @domain.registrant.code == new_registrant.code
    refute @domain.statuses.include? DomainStatus::PENDING_UPDATE
  end
end
