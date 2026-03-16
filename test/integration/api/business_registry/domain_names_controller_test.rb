require 'test_helper'

class Api::V1::BusinessRegistry::DomainNamesControllerTest < ActionDispatch::IntegrationTest
  setup do
    @valid_ip = '127.0.0.1'
    ENV['auction_api_allowed_ips'] = @valid_ip
    @valid_token = 'valid_test_token'
    ENV['business_registry_api_tokens'] = @valid_token

    @auth_headers = {
      'REMOTE_ADDR' => @valid_ip,
      'Authorization' => "Bearer #{@valid_token}"
    }
  end

  test "should return list of available organization domain names" do
    get api_v1_business_registry_domain_names_path(organization_name: "Test Company AS"), headers: @auth_headers
    
    assert_response :success
    json_response = JSON.parse(response.body)
    assert_equal json_response['variants'], ["testcompany.test", "test-company.test"]
  end

  test "should handle invalid organization name" do
    get api_v1_business_registry_domain_names_path(organization_name: "Invalid!@#Name"), headers: @auth_headers
    
    assert_response :bad_request
    json_response = JSON.parse(response.body)
    assert_equal 'Invalid organization name', json_response['error']
  end
end
