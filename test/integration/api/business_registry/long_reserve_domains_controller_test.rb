require 'test_helper'

class LongReserveDomainsControllerTest < ApplicationIntegrationTest
  def setup
    @valid_domain_names = ['example1.test', 'example2.test']
    @success_url = 'https://success.test'
    @failed_url = 'https://failed.test'
    @allowed_origins = ['http://example.com', 'https://test.com']
    ENV['ALLOWED_ORIGINS'] = @allowed_origins.join(',')
    
    stub_invoice_number_request
    stub_add_deposits_request
    stub_oneoff_request

    @valid_ip = '127.0.0.1'
    ENV['auction_api_allowed_ips'] = @valid_ip

    # Mock the domain availability checker
    @original_filter_available = BusinessRegistry::DomainAvailabilityCheckerService.method(:filter_available)
    BusinessRegistry::DomainAvailabilityCheckerService.define_singleton_method(:filter_available) do |domains|
      domains # Return all domains as available for testing
    end
  end

  teardown do
    # Restore original method
    if @original_filter_available
      BusinessRegistry::DomainAvailabilityCheckerService.define_singleton_method(:filter_available, @original_filter_available)
    end
  end

  test "should create long reserve domains with valid parameters" do
    mock_result = OpenStruct.new(
      status_code_success: true,
      linkpay_url: "http://payment.test",
      invoice_number: "123456"
    )

    ReserveDomainInvoice.stub :create_list_of_domains, mock_result do
      post api_v1_business_registry_long_reserve_domains_path,
        params: { 
          domain_names: @valid_domain_names,
          success_business_registry_customer_url: @success_url,
          failed_business_registry_customer_url: @failed_url
        },
        headers: {
          'Origin' => @allowed_origins.first,
          'REMOTE_ADDR' => @valid_ip
        }

      assert_response :created
      json_response = JSON.parse(response.body)
      
      assert_equal "Domains are in pending status. Need to pay for domains.", json_response['message']
      assert_equal "http://payment.test", json_response['linkpay_url']
      assert_equal "123456", json_response['invoice_number']
    end
  end

  test "should return error when domain names parameter is missing" do
    post api_v1_business_registry_long_reserve_domains_path,
      headers: {
        'Origin' => @allowed_origins.first,
        'REMOTE_ADDR' => @valid_ip
      }

    assert_response :bad_request
    json_response = JSON.parse(response.body)
    assert_equal "Invalid parameter: domain_names must be a non-empty array of valid domain names", json_response['error']
  end

  test "should return error when domain names is not an array" do
    post api_v1_business_registry_long_reserve_domains_path,
      params: { domain_names: "not-an-array" },
      headers: {
        'Origin' => @allowed_origins.first,
        'REMOTE_ADDR' => @valid_ip
      }

    assert_response :bad_request
    json_response = JSON.parse(response.body)
    assert_equal "Invalid parameter: domain_names must be a non-empty array of valid domain names", json_response['error']
  end

  test "should return error when domain names exceed maximum limit" do
    domain_names = (1..ReservedDomain::MAX_DOMAIN_NAME_PER_REQUEST + 1).map { |i| "domain#{i}.test" }
    
    post api_v1_business_registry_long_reserve_domains_path,
      params: { domain_names: domain_names },
      headers: {
        'Origin' => @allowed_origins.first,
        'REMOTE_ADDR' => @valid_ip
      }

    assert_response :unprocessable_entity
    json_response = JSON.parse(response.body)
    assert_equal "The maximum number of domain names per request is #{ReservedDomain::MAX_DOMAIN_NAME_PER_REQUEST}", json_response['error']
  end

  test "should return error when domain names contain invalid format" do
    invalid_domain_names = ['invalid!domain.test', 'another@invalid.test']
    
    post api_v1_business_registry_long_reserve_domains_path,
      params: { domain_names: invalid_domain_names },
      headers: {
        'Origin' => @allowed_origins.first,
        'REMOTE_ADDR' => @valid_ip
      }

    assert_response :bad_request
    json_response = JSON.parse(response.body)
    assert_equal "Invalid parameter: domain_names must be a non-empty array of valid domain names", json_response['error']
  end

  test "should return error when reserve domain creation fails" do
    mock_result = OpenStruct.new(
      status_code_success: false,
      details: "Failed to reserve domains"
    )

    ReserveDomainInvoice.stub :create_list_of_domains, mock_result do
      post api_v1_business_registry_long_reserve_domains_path,
        params: { domain_names: @valid_domain_names },
        headers: {
          'Origin' => @allowed_origins.first,
          'REMOTE_ADDR' => @valid_ip
        }

      assert_response :unprocessable_entity
      json_response = JSON.parse(response.body)
      assert_equal "Failed to reserve domains", json_response['error']
    end
  end

  test "should handle missing callback urls" do
    post api_v1_business_registry_long_reserve_domains_path,
      params: { domain_names: @valid_domain_names },
      headers: {
        'Origin' => @allowed_origins.first,
        'REMOTE_ADDR' => @valid_ip
      }

    assert_response :created
    json_response = JSON.parse(response.body)
    assert_not_nil json_response['linkpay_url']
  end

  test "should accept request with valid URLs" do
    mock_result = OpenStruct.new(
      status_code_success: true,
      linkpay_url: "http://payment.test",
      invoice_number: "123456"
    )

    ReserveDomainInvoice.stub :create_list_of_domains, mock_result do
      post api_v1_business_registry_long_reserve_domains_path,
        params: { 
          domain_names: @valid_domain_names,
          success_business_registry_customer_url: "https://success.example.com",
          failed_business_registry_customer_url: "https://failed.example.com"
        },
        headers: {
          'Origin' => @allowed_origins.first,
          'REMOTE_ADDR' => @valid_ip
        }

      assert_response :created
      json_response = JSON.parse(response.body)
      assert_not_nil json_response['linkpay_url']
    end
  end

  test "should check domain availability before creating" do
    # Mock the availability checker to return no available domains
    BusinessRegistry::DomainAvailabilityCheckerService.define_singleton_method(:filter_available) do |domains|
      []
    end

    post api_v1_business_registry_long_reserve_domains_path,
      params: { domain_names: @valid_domain_names },
      headers: {
        'Origin' => @allowed_origins.first,
        'REMOTE_ADDR' => @valid_ip
      }

    assert_response :unprocessable_entity
    json_response = JSON.parse(response.body)
    assert_equal "No available domains", json_response['error']
  end

  test "should check if any domains are available before processing" do
    ReserveDomainInvoice.stub :is_any_available_domains?, false do
      post api_v1_business_registry_long_reserve_domains_path,
        params: { domain_names: @valid_domain_names },
        headers: {
          'Origin' => @allowed_origins.first,
          'REMOTE_ADDR' => @valid_ip
        }

      assert_response :unprocessable_entity
      json_response = JSON.parse(response.body)
      assert_equal "No available domains", json_response['error']
    end
  end

  test "should return available domains in response" do
    mock_result = OpenStruct.new(
      status_code_success: true,
      linkpay_url: "http://payment.test",
      invoice_number: "123456",
      user_unique_id: "user123"
    )

    ReserveDomainInvoice.stub :create_list_of_domains, mock_result do
      ReserveDomainInvoice.stub :filter_available_domains, @valid_domain_names do
        post api_v1_business_registry_long_reserve_domains_path,
          params: { domain_names: @valid_domain_names },
          headers: {
            'Origin' => @allowed_origins.first,
            'REMOTE_ADDR' => @valid_ip
          }

        assert_response :created
        json_response = JSON.parse(response.body)
        assert_equal @valid_domain_names, json_response['available_domains']
        assert_equal "user123", json_response['user_unique_id']
      end
    end
  end

  private

  def stub_invoice_number_request
    stub_request(:post, "https://eis_billing_system:3000/api/v1/invoice_generator/invoice_number_generator")
      .to_return(status: 200, body: { invoice_number: '12345' }.to_json, headers: {})
  end

  def stub_add_deposits_request
    stub_request(:post, "https://eis_billing_system:3000/api/v1/invoice_generator/invoice_generator")
      .to_return(status: 201, body: { everypay_link: 'https://pay.test' }.to_json)
  end

  def stub_oneoff_request
    stub_request(:post, "https://eis_billing_system:3000/api/v1/invoice_generator/oneoff")
      .to_return(status: 200, body: { oneoff_redirect_link: 'https://payment.test' }.to_json)
  end
end
