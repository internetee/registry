require 'test_helper'

class ReppV1DomainsStatusesTest < ActionDispatch::IntegrationTest
  def setup
    @user = users(:api_bestnames)
    @domain = domains(:shop)
    token = Base64.encode64("#{@user.username}:#{@user.plain_text_password}")
    token = "Basic #{token}"

    @auth_headers = { 'Authorization' => token }

    adapter = ENV["shunter_default_adapter"].constantize.new
    adapter&.clear!
  end

  def test_client_hold_can_be_added
    refute @domain.statuses.include?(DomainStatus::CLIENT_HOLD)
    put repp_v1_domain_status_path(domain_id: @domain.name, id: DomainStatus::CLIENT_HOLD), headers: @auth_headers
    json = JSON.parse(response.body, symbolize_names: true)

    assert_response :ok
    @domain.reload

    assert @domain.statuses.include?(DomainStatus::CLIENT_HOLD)
  end

  def test_client_hold_can_be_removed
    statuses = @domain.statuses << DomainStatus::CLIENT_HOLD
    @domain.update(statuses: statuses)
    delete repp_v1_domain_status_path(domain_id: @domain.name, id: DomainStatus::CLIENT_HOLD), headers: @auth_headers

    assert_response :ok
    @domain.reload
    refute @domain.statuses.include?(DomainStatus::CLIENT_HOLD)
  end

  def test_can_not_remove_disallowed_statuses
    statuses = @domain.statuses << DomainStatus::FORCE_DELETE
    @domain.update(statuses: statuses)

    delete repp_v1_domain_status_path(domain_id: @domain.name, id: DomainStatus::FORCE_DELETE), headers: @auth_headers
    @domain.reload
    json = JSON.parse(response.body, symbolize_names: true)

    assert_response :bad_request
    assert_equal 'Parameter value policy error. Client-side object status management not supported: status serverForceDelete', json[:message]

    assert @domain.statuses.include?(DomainStatus::FORCE_DELETE)
  end

  def test_can_not_add_disallowed_statuses
    put repp_v1_domain_status_path(domain_id: @domain.name, id: DomainStatus::DELETE_CANDIDATE), headers: @auth_headers
    @domain.reload
    json = JSON.parse(response.body, symbolize_names: true)

    assert_response :bad_request
    assert_equal 'Parameter value policy error. Client-side object status management not supported: status deleteCandidate', json[:message]

    refute @domain.statuses.include?(DomainStatus::DELETE_CANDIDATE)
  end

  def test_can_not_remove_unexistant_status
    refute @domain.statuses.include?(DomainStatus::CLIENT_HOLD)
    delete repp_v1_domain_status_path(domain_id: @domain.name, id: DomainStatus::CLIENT_HOLD), headers: @auth_headers
    json = JSON.parse(response.body, symbolize_names: true)

    assert_response :bad_request
    assert_equal 'Parameter value policy error. Client-side object status management not supported: status clientHold', json[:message]
  end

  def test_returns_normal_error_when_action_fails
    @invalid_domain = domains(:invalid)

    put repp_v1_domain_status_path(domain_id: @invalid_domain.name, id: DomainStatus::CLIENT_HOLD), headers: @auth_headers
    json = JSON.parse(response.body, symbolize_names: true)
    assert_response :bad_request
    assert_equal 2304, json[:code]

    delete repp_v1_domain_status_path(domain_id: @invalid_domain.name, id: DomainStatus::FORCE_DELETE), headers: @auth_headers
    json = JSON.parse(response.body, symbolize_names: true)
    assert_response :bad_request
    assert_equal 2306, json[:code]
  end

  def test_returns_error_response_if_throttled
    ENV["shunter_default_threshold"] = '1'
    ENV["shunter_enabled"] = 'true'

    put repp_v1_domain_status_path(domain_id: @domain.name, id: DomainStatus::CLIENT_HOLD), headers: @auth_headers
    put repp_v1_domain_status_path(domain_id: @domain.name, id: DomainStatus::CLIENT_HOLD), headers: @auth_headers
    json = JSON.parse(response.body, symbolize_names: true)

    assert_response :bad_request
    assert_equal json[:code], 2502
    assert response.body.include?(Shunter.default_error_message)
    ENV["shunter_default_threshold"] = '10000'
    ENV["shunter_enabled"] = 'false'
  end
end
