require 'test_helper'

class LongReserveDomainsControllerTest < ApplicationIntegrationTest
  def setup
    @valid_domain_names = ['example1.test', 'example2.test']
    @allowed_origins = ['http://example.com', 'https://test.com']
    ENV['ALLOWED_ORIGINS'] = @allowed_origins.join(',')
    
    @valid_ip = '127.0.0.1'
    @invalid_ip = '192.168.1.1'
    ENV['auction_api_allowed_ips'] = @valid_ip
  end

  test "should create long reserve domains with valid parameters" do
    mock_result = OpenStruct.new(
      status_code_success: true,
      linkpay: "http://payment.test",
      invoice_number: "123456"
    )

    ReserveDomainInvoice.stub :create_list_of_domains, mock_result do
      post api_v1_business_registry_long_reserve_domains_path,
        params: { domain_names: @valid_domain_names },
        headers: {
          'Origin' => @allowed_origins.first,
          'REMOTE_ADDR' => @valid_ip
        }

      assert_response :created
      json_response = JSON.parse(response.body)
      
      assert_equal "Domains are in pending status. Need to pay for domains.", json_response['message']
      assert_equal "http://payment.test", json_response['linkpay']
      assert_equal "123456", json_response['invoice_number']
      assert_equal @allowed_origins.first, response.headers['Access-Control-Allow-Origin']
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
end
