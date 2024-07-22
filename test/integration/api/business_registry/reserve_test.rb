require 'test_helper'

class ReserveTest < ApplicationIntegrationTest
  fixtures :reserved_domains
  fixtures 'dns/zones'

  def setup
    @valid_domain = 'newdomain.test'
    @existing_domain = reserved_domains(:one).name
    @blocked_domain = 'blocked-domain.test'
    BlockedDomain.create(name: @blocked_domain)
    @zone_domain = dns_zones(:one).origin
    @allowed_origins = ['http://example.com', 'https://test.com']
    ENV['ALLOWED_ORIGINS'] = @allowed_origins.join(',')

    @valid_ip = '127.0.0.1'
    @invalid_ip = '192.168.1.1'
    ENV['auction_api_allowed_ips'] = @valid_ip
  end

  test "should reserve a new domain" do
    assert_difference('ReservedDomain.count') do
      post api_v1_business_registry_reserve_path, 
           params: { name: @valid_domain },
           headers: { 'Origin' => @allowed_origins.first, 'REMOTE_ADDR' => @valid_ip }
    end
    assert_response :created
    assert_equal @allowed_origins.first, response.headers['Access-Control-Allow-Origin']
    json_response = JSON.parse(response.body)
    assert_not_nil json_response['token']
  end

  test "should return existing domain if already reserved" do
    assert_no_difference('ReservedDomain.count') do
      post api_v1_business_registry_reserve_path, 
           params: { name: @existing_domain },
           headers: { 'Origin' => @allowed_origins.first, 'REMOTE_ADDR' => @valid_ip }
    end
    assert_response :ok
    json_response = JSON.parse(response.body)
    assert_equal "Domain already reserved", json_response['message']
    assert_not_nil json_response['token']
  end

  test "should return error for missing name parameter" do
    post api_v1_business_registry_reserve_path, 
         params: {},
         headers: { 'Origin' => @allowed_origins.first, 'REMOTE_ADDR' => @valid_ip }
    assert_response :bad_request
    json_response = JSON.parse(response.body)
    assert_equal "Missing required parameter: name", json_response['error']
  end

  test "should handle invalid domain names" do
    post api_v1_business_registry_reserve_path, 
         params: { name: 'invalid domain' },
         headers: { 'Origin' => @allowed_origins.first, 'REMOTE_ADDR' => @valid_ip }
    assert_response :unprocessable_entity
    json_response = JSON.parse(response.body)
    assert_includes json_response['details'], "Name is invalid"
  end

  test "should handle blocked domain names" do
    post api_v1_business_registry_reserve_path, 
         params: { name: @blocked_domain },
         headers: { 'Origin' => @allowed_origins.first, 'REMOTE_ADDR' => @valid_ip }
    assert_response :unprocessable_entity
    json_response = JSON.parse(response.body)
    assert_includes json_response['details'], "Data management policy violation: Domain name is blocked [name]"
  end

  test "should not allow reserving a zone domain" do
    post api_v1_business_registry_reserve_path, 
         params: { name: @zone_domain },
         headers: { 'Origin' => @allowed_origins.first, 'REMOTE_ADDR' => @valid_ip }
    assert_response :unprocessable_entity
    json_response = JSON.parse(response.body)
    assert_includes json_response['details'], "Data management policy violation: Domain name is blocked [name]"
  end
end