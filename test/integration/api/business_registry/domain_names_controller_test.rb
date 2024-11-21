require 'test_helper'

class Api::V1::BusinessRegistry::DomainNamesControllerTest < ActionDispatch::IntegrationTest
  setup do
    @valid_ip = '127.0.0.1'
    ENV['auction_api_allowed_ips'] = @valid_ip
  end

  test "should return list of available organization domain names" do
    get api_v1_business_registry_domain_names_path(organization_name: "Test Company AS")
    
    assert_response :success
    json_response = JSON.parse(response.body)
    assert_equal json_response['variants'], ["testcompany.test", "test-company.test"]
  end

  test "should handle invalid organization name" do
    get api_v1_business_registry_domain_names_path(organization_name: "Invalid!@#Name")
    
    assert_response :bad_request
    json_response = JSON.parse(response.body)
    assert_equal 'Invalid organization name', json_response['error']
  end
end
