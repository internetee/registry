require 'test_helper'

class Api::V1::BusinessRegistry::BaseControllerTest < ActionDispatch::IntegrationTest
  def setup
    super
    @valid_token = 'valid_test_token'
    ENV['business_registry_api_tokens'] = @valid_token
  end

  def test_rejects_request_without_token
    post api_v1_business_registry_reserve_domains_path, params: {}
    assert_response :unauthorized
    
    json_response = JSON.parse(response.body)
    assert_equal 'Unauthorized', json_response['error']
  end

  def test_rejects_request_with_invalid_token
    headers = { 'Authorization' => 'Bearer invalid_token' }
    post api_v1_business_registry_reserve_domains_path, 
         params: {},
         headers: headers
    
    assert_response :unauthorized
    json_response = JSON.parse(response.body)
    assert_equal 'Unauthorized', json_response['error']
  end

  def test_accepts_request_with_valid_token
    headers = { 'Authorization' => "Bearer #{@valid_token}" }
    domain_names = ["new1.test", "new2.test"]
    post api_v1_business_registry_reserve_domains_path, 
         params: { domain_names: domain_names },
         headers: headers
    
    assert_response :success
  end

  def test_handles_malformed_authorization_header
    headers = { 'Authorization' => 'malformed_header' }
    post api_v1_business_registry_reserve_domains_path, 
         params: {},
         headers: headers
    
    assert_response :unauthorized
    json_response = JSON.parse(response.body)
    assert_equal 'Unauthorized', json_response['error']
  end
end 