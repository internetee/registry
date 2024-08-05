require 'test_helper'

class Api::V1::BusinessRegistry::DomainNamesControllerTest < ActionDispatch::IntegrationTest
  setup do
    @allowed_origins = ['http://example.com', 'https://test.com']
    ENV['ALLOWED_ORIGINS'] = @allowed_origins.join(',')
    @valid_ip = '127.0.0.1'
    ENV['auction_api_allowed_ips'] = @valid_ip
  end

  test "should return list of available organization domain names" do
    get api_v1_business_registry_domain_names_path(organization_name: "Test Company AS"), 
        headers: { 'Origin' => @allowed_origins.first, 'REMOTE_ADDR' => @valid_ip }
    
    assert_response :success
    assert_equal @allowed_origins.first, response.headers['Access-Control-Allow-Origin']
    json_response = JSON.parse(response.body)
    assert_includes json_response['variants'], 'testcompanyas'
    assert_includes json_response['variants'], 'test-company-as'
    assert_includes json_response['variants'], 'test_company_as'
    assert_includes json_response['variants'], "testcompany#{Time.current.year}"
  end

  test "should handle invalid organization name" do
    get api_v1_business_registry_domain_names_path(organization_name: "Invalid!@#Name"), 
        headers: { 'Origin' => @allowed_origins.first, 'REMOTE_ADDR' => @valid_ip }
    
    assert_response :bad_request
    json_response = JSON.parse(response.body)
    assert_equal 'Invalid organization name', json_response['error']
  end

  test "should not set CORS header for disallowed origin" do
    get api_v1_business_registry_domain_names_path(organization_name: "Test Company"), 
        headers: { 'Origin' => 'http://malicious.com', 'REMOTE_ADDR' => @valid_ip }
    
    assert_response :unauthorized
    assert_nil response.headers['Access-Control-Allow-Origin']
  end

  test "should not allow access from unauthorized IP" do
    get api_v1_business_registry_domain_names_path(organization_name: "Test Company"), 
        headers: { 'Origin' => @allowed_origins.first, 'REMOTE_ADDR' => '192.168.1.1' }
    
    assert_response :unauthorized
  end
end
