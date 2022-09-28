require 'test_helper'

class ReppV1DomainsDeleteTest < ActionDispatch::IntegrationTest
  def setup
    @user = users(:api_bestnames)
    @domain = domains(:shop)
    token = Base64.encode64("#{@user.username}:#{@user.plain_text_password}")
    token = "Basic #{token}"

    @auth_headers = { 'Authorization' => token }
  end

  def test_domain_pending_delete_confirmation
    Setting.request_confirmation_on_domain_deletion_enabled = true
    @auth_headers['Content-Type'] = 'application/json'

    payload = {
      domain: {
        delete: {
          verified: false,
        },
      },
    }

    delete "/repp/v1/domains/#{@domain.name}", headers: @auth_headers, params: payload.to_json
    @domain.reload
    json = JSON.parse(response.body, symbolize_names: true)
    assert_response :ok
    assert_equal 1000, json[:code]
    assert_equal 'Command completed successfully', json[:message]

    assert @domain.statuses.include? DomainStatus::PENDING_DELETE_CONFIRMATION
    assert_not @domain.statuses.include? DomainStatus::PENDING_DELETE
  end

  def test_domain_pending_delete_on_verified_delete
    Setting.request_confirmation_on_domain_deletion_enabled = true
    @auth_headers['Content-Type'] = 'application/json'

    payload = {
      domain: {
        delete: {
          verified: true,
        },
      },
    }

    delete "/repp/v1/domains/#{@domain.name}", headers: @auth_headers, params: payload.to_json
    @domain.reload
    json = JSON.parse(response.body, symbolize_names: true)
    assert_response :ok
    assert_equal 1000, json[:code]
    assert_equal 'Command completed successfully', json[:message]

    refute @domain.statuses.include? DomainStatus::PENDING_DELETE_CONFIRMATION
    assert @domain.statuses.include? DomainStatus::PENDING_DELETE
  end
end
