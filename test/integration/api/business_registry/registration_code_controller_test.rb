require 'test_helper'

class RegistrationCodeTest < ApplicationIntegrationTest
  fixtures :reserved_domains

  def setup
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

  test "should return registration code for a valid token" do
    get api_v1_business_registry_registration_code_path, 
      headers: { 
        'Authorization' => "Bearer #{@reserved_domain_status.access_token}",
        'Origin' => @allowed_origins.first,
        'REMOTE_ADDR' => @valid_ip
      }
    assert_response :success
    assert_equal @allowed_origins.first, response.headers['Access-Control-Allow-Origin']
    json_response = JSON.parse(response.body)
    assert_equal @reserved_domain.name, json_response['name']
    assert_equal @reserved_domain.password, json_response['registration_code']
  end

  test "should return error for expired token" do
    @reserved_domain_status.update(token_created_at: 31.days.ago)
    get api_v1_business_registry_registration_code_path, 
        headers: { 
          'Authorization' => "Bearer #{@reserved_domain_status.access_token}",
          'Origin' => @allowed_origins.first,
          'REMOTE_ADDR' => @valid_ip
        }
    assert_response :unauthorized
    json_response = JSON.parse(response.body)
    assert_equal "Token expired. Please refresh the token. TODO: provide endpoint", json_response['error']
  end

  test "should return error for invalid token" do
    get api_v1_business_registry_registration_code_path, 
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
    get api_v1_business_registry_registration_code_path, 
        headers: { 
          'Authorization' => "Bearer #{@reserved_domain_status.access_token}",
          'Origin' => 'http://malicious.com',
          'REMOTE_ADDR' => @valid_ip
        }
    assert_response :unauthorized
    assert_nil response.headers['Access-Control-Allow-Origin']
  end
end