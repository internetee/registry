require 'test_helper'

class ReleaseTest < ApplicationIntegrationTest
  fixtures :reserved_domains

  def setup
    @reserved_domain = reserved_domains(:one)
    @reserved_domain.update(token_created_at: Time.current)
    @allowed_origins = ['http://example.com', 'https://test.com']
    ENV['ALLOWED_ORIGINS'] = @allowed_origins.join(',')

    @valid_ip = '127.0.0.1'
    @invalid_ip = '192.168.1.1'
    ENV['auction_api_allowed_ips'] = @valid_ip
  end

  test "should release a reserved domain with valid token" do
    @reserved_domain.refresh_token # Обновляем токен перед тестом
    assert_difference('ReservedDomain.count', -1) do
      delete api_v1_business_registry_release_path, 
             headers: { 
               'Authorization' => "Bearer #{@reserved_domain.reload.access_token}",
               'Origin' => @allowed_origins.first,
               'REMOTE_ADDR' => @valid_ip
             }
    end
    assert_response :success
    assert_equal @allowed_origins.first, response.headers['Access-Control-Allow-Origin']
    json_response = JSON.parse(response.body)
    assert_equal "Domain '#{@reserved_domain.name}' has been successfully released", json_response['message']
  end

  test "should return error for invalid token" do
    delete api_v1_business_registry_release_path, 
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
          'Authorization' => "Bearer #{@reserved_domain.access_token}",
          'Origin' => 'http://malicious.com',
          'REMOTE_ADDR' => @valid_ip
        }
    assert_response :unauthorized
    assert_nil response.headers['Access-Control-Allow-Origin']
  end
end