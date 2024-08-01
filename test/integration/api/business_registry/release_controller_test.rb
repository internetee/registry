require 'test_helper'

class Api::V1::BusinessRegistry::ReleaseControllerTest < ActionDispatch::IntegrationTest
  def setup
    @reserved_domain = ReservedDomain.create(name: 'example.test')
    @reserved_domain_status = ReservedDomainStatus.create(
      name: 'example.test',
      access_token: 'valid_token',
      token_created_at: Time.current,
      reserved_domain: @reserved_domain
    )
    ENV['ALLOWED_ORIGINS'] = 'https://example.com,https://test.com'
    ENV['auction_api_allowed_ips'] = '127.0.0.1'
    ENV['eis_billing_system_base_url'] = 'https://eis_billing_system:3000'

    stub_request(:patch, "#{ENV['eis_billing_system_base_url']}/api/v1/invoice/reserved_domain_cancellation_statuses")
      .to_return(status: 200, body: "", headers: {})
  end

  def common_headers
    {
      'Authorization' => "Bearer #{@reserved_domain_status.access_token}",
      'Origin' => 'https://example.com',
      'REMOTE_ADDR' => '127.0.0.1'
    }
  end

  test "destroy releases domain successfully" do
    assert_difference('ReservedDomainStatus.count', -1) do
      delete api_v1_business_registry_release_url, headers: common_headers
    end

    assert_response :success
    assert_equal 'https://example.com', response.headers['Access-Control-Allow-Origin']
    assert_equal({ 'message' => "Domain 'example.test' has been successfully released" }, JSON.parse(response.body))
    assert_requested :patch, "#{ENV['eis_billing_system_base_url']}/api/v1/invoice/reserved_domain_cancellation_statuses"
  end

  test "destroy fails with expired token" do
    @reserved_domain_status.update(token_created_at: 31.days.ago)

    delete api_v1_business_registry_release_url, headers: common_headers

    assert_response :unauthorized
    assert_equal({ 'error' => "Token expired. Please refresh the token: PATCH || PUT '/api/v1/business_registry/refresh_token'" }, JSON.parse(response.body))
  end

  test "destroy fails with invalid token" do
    invalid_headers = common_headers.merge('Authorization' => 'Bearer invalid_token')
    delete api_v1_business_registry_release_url, headers: invalid_headers

    assert_response :unauthorized
    assert_equal({ 'error' => 'Invalid token' }, JSON.parse(response.body))
  end

  test "destroy fails when domain release fails" do
    ReservedDomainStatus.stub :find_by, @reserved_domain_status do
      @reserved_domain_status.stub :destroy, false do
        @reserved_domain_status.stub :errors, OpenStruct.new(full_messages: ['Some error']) do
          delete api_v1_business_registry_release_url, headers: common_headers
        end
      end
    end

    assert_response :unprocessable_entity
    assert_equal({ 'error' => 'Failed to release domain', 'details' => ['Some error'] }, JSON.parse(response.body))
  end

  test "destroy returns error for unauthorized origin" do
    unauthorized_headers = common_headers.merge('Origin' => 'https://unauthorized.com')
    delete api_v1_business_registry_release_url, headers: unauthorized_headers

    assert_response :unauthorized
    assert_equal({ 'error' => 'Unauthorized origin' }, JSON.parse(response.body))
  end

  test "destroy fails with unauthorized IP" do
    unauthorized_headers = common_headers.merge('REMOTE_ADDR' => '192.168.1.1')
    delete api_v1_business_registry_release_url, headers: unauthorized_headers

    assert_response :unauthorized
  end
end