require 'test_helper'
require 'webmock/minitest'

class Api::V1::BusinessRegistry::ReserveControllerTest < ActionDispatch::IntegrationTest
  def setup
    @valid_domain = 'newdomain.test'
    @existing_domain = reserved_domains(:one).name
    @valid_params = { 
      domain_name: @valid_domain
    }
    @allowed_origins = ['http://example.com', 'https://test.com']
    ENV['ALLOWED_ORIGINS'] = @allowed_origins.join(',')
    @valid_ip = '127.0.0.1'
    ENV['auction_api_allowed_ips'] = @valid_ip
    ENV['eis_billing_system_base_url'] = 'https://eis_billing_system:3000'
    ENV['billing_secret'] = 'test_secret'

    stub_invoice_number_request
    stub_add_deposits_request
  end

  test "should reserve a new domain" do
    assert_difference('ReservedDomainStatus.count') do
      post api_v1_business_registry_reserve_path, 
           params: @valid_params, 
           headers: { 'Origin' => @allowed_origins.first, 'REMOTE_ADDR' => @valid_ip }
    end

    assert_response :created
    json_response = JSON.parse(response.body)
    assert_not_nil json_response['token']
    assert_not_nil json_response['linkpay']
  end

  test "should return existing domain if already reserved" do
    assert_no_difference('ReservedDomainStatus.count') do
      post api_v1_business_registry_reserve_path, 
           params: @valid_params.merge(domain_name: @existing_domain),
           headers: { 'Origin' => @allowed_origins.first, 'REMOTE_ADDR' => @valid_ip }
    end

    assert_response :ok
    json_response = JSON.parse(response.body)
    assert_equal "Domain already reserved", json_response['message']
  end

  test "should handle errors when saving ReservedDomainStatus" do
    ReservedDomainStatus.stub_any_instance(:save, false) do
      post api_v1_business_registry_reserve_path, 
           params: @valid_params,
           headers: { 'Origin' => @allowed_origins.first, 'REMOTE_ADDR' => @valid_ip }

      assert_response :unprocessable_entity
      json_response = JSON.parse(response.body)
      assert_equal "Failed to reserve domain", json_response['error']
      assert_not_nil json_response['details']
    end
  end

  test "should handle missing parameters" do
    post api_v1_business_registry_reserve_path, 
         params: {},
         headers: { 'Origin' => @allowed_origins.first, 'REMOTE_ADDR' => @valid_ip }

    assert_response :bad_request
    json_response = JSON.parse(response.body)
    assert_equal "Missing required parameter: name", json_response['error']
  end

  test "should handle unauthorized origin" do
    post api_v1_business_registry_reserve_path, 
         params: @valid_params,
         headers: { 'Origin' => 'http://unauthorized.com', 'REMOTE_ADDR' => @valid_ip }

    assert_response :unauthorized
    json_response = JSON.parse(response.body)
    assert_equal "Unauthorized origin", json_response['error']
  end

  private

  def stub_invoice_number_request
    stub_request(:post, "#{ENV['eis_billing_system_base_url']}/api/v1/invoice_generator/invoice_number_generator")
      .to_return(status: 200, body: { invoice_number: '12345' }.to_json, headers: { 'Content-Type' => 'application/json' })
  end

  def stub_add_deposits_request
    stub_request(:post, "#{ENV['eis_billing_system_base_url']}/api/v1/invoice_generator/invoice_generator")
      .to_return(status: 201, body: { everypay_link: 'https://pay.example.com' }.to_json, headers: { 'Content-Type' => 'application/json' })
  end
end
