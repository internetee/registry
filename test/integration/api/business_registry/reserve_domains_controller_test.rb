require 'test_helper'

class Api::V1::BusinessRegistry::ReserveDomainsControllerTest < ActionDispatch::IntegrationTest
  def setup
    @allowed_origins = ['http://example.com', 'https://test.com']
    ENV['ALLOWED_ORIGINS'] = @allowed_origins.join(',')
    @valid_ip = '127.0.0.1'
    ENV['auction_api_allowed_ips'] = @valid_ip
    @valid_token = 'valid_test_token'
    ENV['business_registry_api_tokens'] = @valid_token

    @auth_headers = {
      'Origin' => @allowed_origins.first,
      'REMOTE_ADDR' => @valid_ip,
      'Authorization' => "Bearer #{@valid_token}"
    }

    @original_filter_available = BusinessRegistry::DomainAvailabilityCheckerService.method(:filter_available)
    BusinessRegistry::DomainAvailabilityCheckerService.define_singleton_method(:filter_available) do |domains|
      domains
    end
  end

  teardown do
    if @original_filter_available
      BusinessRegistry::DomainAvailabilityCheckerService.define_singleton_method(:filter_available, @original_filter_available)
    end
  end

  test "should reserve multiple domains successfully" do
    domain_names = ["new1.test", "new2.test"]
    
    assert_difference ['ReservedDomain.count'], 2 do
      post api_v1_business_registry_reserve_domains_path,
           params: { domain_names: domain_names },
           headers: @auth_headers
    end

    assert_response :created
    json_response = JSON.parse(response.body)
    assert_equal "Domains reserved successfully", json_response['message']
    assert_equal 2, json_response['reserved_domains'].length
    assert_not_nil json_response['user_unique_id']
    assert_equal 10, json_response['user_unique_id'].length
    
    json_response['reserved_domains'].each do |domain|
      assert domain_names.include?(domain['name'])
      assert_not_nil domain['password']
    end
  end

  test "should handle invalid domain names" do
    post api_v1_business_registry_reserve_domains_path,
         params: { domain_names: ["invalid@domain.test"] },
         headers: @auth_headers

    assert_response :bad_request
    json_response = JSON.parse(response.body)
    assert_includes json_response['error'], "Invalid parameter: domain_names"
  end

  test "should handle empty domain names array" do
    post api_v1_business_registry_reserve_domains_path,
         params: { domain_names: [] },
         headers: @auth_headers

    assert_response :bad_request
    json_response = JSON.parse(response.body)
    assert_includes json_response['error'], "Invalid parameter: domain_names"
  end

  test "should handle missing domain_names parameter" do
    post api_v1_business_registry_reserve_domains_path,
         params: {},
         headers: @auth_headers

    assert_response :bad_request
    json_response = JSON.parse(response.body)
    assert_includes json_response['error'], "Invalid parameter: domain_names"
  end

  test "should handle exceeding maximum domains per request" do
    domain_names = (1..ReservedDomain::MAX_DOMAIN_NAME_PER_REQUEST + 1).map { |i| "valid-domain#{i}.test" }
    
    post api_v1_business_registry_reserve_domains_path,
         params: { domain_names: domain_names },
         headers: @auth_headers

    assert_response :unprocessable_entity
    json_response = JSON.parse(response.body)
    assert_includes json_response['error'], "The maximum number of domain names per request is #{ReservedDomain::MAX_DOMAIN_NAME_PER_REQUEST}"
  end

  test "should reserve multiple domains successfully with correct expiration" do
    domain_names = ["new1.test", "new2.test"]
    
    assert_difference 'ReservedDomain.count', 2 do
      post api_v1_business_registry_reserve_domains_path,
           params: { domain_names: domain_names },
           headers: @auth_headers
    end

    assert_response :created
    json_response = JSON.parse(response.body)
    assert_equal "Domains reserved successfully", json_response['message']
    assert_equal 2, json_response['reserved_domains'].length
    
    json_response['reserved_domains'].each do |domain|
      assert domain_names.include?(domain['name'])
      assert_not_nil domain['password']
      assert_not_nil domain['expire_at']
      
      expire_at = Time.parse(domain['expire_at'])
      assert_in_delta Time.current + ReservedDomain::FREE_RESERVATION_EXPIRY, expire_at, 5.seconds
    end
  end

  test "should set correct expiration time for free reservations" do
    domain_name = "new1.test"
    
    post api_v1_business_registry_reserve_domains_path,
         params: { domain_names: [domain_name] },
         headers: @auth_headers

    assert_response :created
    json_response = JSON.parse(response.body)
    domain = json_response['reserved_domains'].first
    
    expire_at = Time.parse(domain['expire_at'])
    assert_in_delta Time.current + ReservedDomain::FREE_RESERVATION_EXPIRY, expire_at, 5.seconds
  end

  test "should return error when no domains are available" do
    domain_names = ["new1.test", "new2.test"]
    
    BusinessRegistry::DomainAvailabilityCheckerService.stub :filter_available, [] do
      post api_v1_business_registry_reserve_domains_path,
           params: { domain_names: domain_names },
           headers: @auth_headers

      assert_response :unprocessable_entity
      json_response = JSON.parse(response.body)
      assert_equal "No available domains", json_response['error']
    end
  end

  test "should get reserved domains info by user_unique_id" do
    # Create test data
    domain_names = ["test1.test", "test2.test"]
    result = ReservedDomain.reserve_domains_without_payment(domain_names)
    
    # Make request
    get api_v1_business_registry_reserve_domains_data_path(user_unique_id: result.user_unique_id),
        headers: @auth_headers

    assert_response :success
    json_response = JSON.parse(response.body)
    
    # Check response structure
    assert_equal 2, json_response.length
    json_response.each do |domain|
      assert_includes domain_names, domain['name']
      assert_not_nil domain['password']
      assert_not_nil domain['expire_at']
      assert Time.parse(domain['expire_at']) > Time.current
    end
  end

  test "should return error for non-existent user_unique_id" do
    get api_v1_business_registry_reserve_domains_data_path(user_unique_id: 'non-existent'),
        headers: @auth_headers

    assert_response :not_found
    json_response = JSON.parse(response.body)
    assert_equal "Reserved domains not found. Invalid user_unique_id", json_response['error']
  end
end