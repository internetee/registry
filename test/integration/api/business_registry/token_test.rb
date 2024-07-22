require 'test_helper'

class TokenTest < ApplicationIntegrationTest
  setup do
    @reserved_domain = reserved_domains(:one)
    @reserved_domain.refresh_token
    @reserved_domain.update(token_created_at: Time.current)
    @allowed_origins = ['http://example.com', 'https://test.com']
    ENV['ALLOWED_ORIGINS'] = @allowed_origins.join(',')

    @valid_ip = '127.0.0.1'
    @invalid_ip = '192.168.1.1'
    ENV['auction_api_allowed_ips'] = @valid_ip
  end

  test "should refresh expired token" do
    @reserved_domain.update(token_created_at: 31.days.ago)
    old_token = @reserved_domain.access_token
    @reserved_domain.reload

    patch api_v1_business_registry_token_path, 
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

  test "should not refresh valid token" do
    @reserved_domain.refresh_token # Обновляем токен перед тестом
    old_token = @reserved_domain.reload.access_token
    patch api_v1_business_registry_token_path, 
          headers: { 
            'Authorization' => "Bearer #{old_token}",
            'Origin' => @allowed_origins.first,
            'REMOTE_ADDR' => @valid_ip
          }
    assert_response :success
    assert_equal @allowed_origins.first, response.headers['Access-Control-Allow-Origin']
    json_response = JSON.parse(response.body)
    assert_equal "Token is still valid", json_response['message']
    assert_equal old_token, json_response['token']
  end

  test "should return error for invalid token" do
    patch api_v1_business_registry_token_path, 
          headers: { 
            'Authorization' => "Bearer invalid_token",
            'Origin' => @allowed_origins.first,
            'REMOTE_ADDR' => @valid_ip
          }
    assert_response :unauthorized
    json_response = JSON.parse(response.body)
    assert_equal "Invalid token", json_response['error']
  end
end