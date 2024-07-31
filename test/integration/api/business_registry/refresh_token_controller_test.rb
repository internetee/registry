require 'test_helper'

class Api::V1::BusinessRegistry::RefreshTokenControllerTest < ActionDispatch::IntegrationTest
  setup do
    @reserved_domain = reserved_domains(:one)
    @reserved_domain_status = ReservedDomainStatus.create(
      reserved_domain: @reserved_domain,
      name: @reserved_domain.name,
      token_created_at: Time.current
    )
    @reserved_domain_status.refresh_token
    @allowed_origins = ['http://example.com', 'https://test.com']
    ENV['ALLOWED_ORIGINS'] = @allowed_origins.join(',')

    @valid_ip = '127.0.0.1'
    @invalid_ip = '192.168.1.1'
    ENV['auction_api_allowed_ips'] = @valid_ip
  end

  test "should refresh token" do
    old_token = @reserved_domain_status.access_token
    patch api_v1_business_registry_refresh_token_path, 
          headers: { 
            'Authorization' => "Bearer #{old_token}",
            'Origin' => @allowed_origins.first,
            'REMOTE_ADDR' => @valid_ip
          }
    assert_response :success
    assert_equal @allowed_origins.first, response.headers['Access-Control-Allow-Origin']
    json_response = JSON.parse(response.body)
    assert_equal "Token refreshed", json_response['message']
    assert_not_equal old_token, json_response['token']
  end

  test "should return error for invalid token" do
    patch api_v1_business_registry_refresh_token_path, 
          headers: { 
            'Authorization' => "Bearer invalid_token",
            'Origin' => @allowed_origins.first,
            'REMOTE_ADDR' => @valid_ip
          }
    assert_response :unauthorized
    json_response = JSON.parse(response.body)
    assert_equal "Invalid token", json_response['error']
  end

  test "should not set CORS header for disallowed origin" do
    patch api_v1_business_registry_refresh_token_path, 
          headers: { 
            'Authorization' => "Bearer #{@reserved_domain_status.access_token}",
            'Origin' => 'http://malicious.com',
            'REMOTE_ADDR' => @valid_ip
          }
    assert_response :unauthorized
    assert_nil response.headers['Access-Control-Allow-Origin']
  end

  test "should not allow refresh from unauthorized IP" do
    patch api_v1_business_registry_refresh_token_path, 
          headers: { 
            'Authorization' => "Bearer #{@reserved_domain_status.access_token}",
            'Origin' => @allowed_origins.first,
            'REMOTE_ADDR' => @invalid_ip
          }
    assert_response :unauthorized
  end
end