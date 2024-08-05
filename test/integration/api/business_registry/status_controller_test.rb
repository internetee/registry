require 'test_helper'

class Api::V1::BusinessRegistry::StatusControllerTest < ActionDispatch::IntegrationTest
  setup do
    @reserved_domain_status = ReservedDomainStatus.create(name: 'example.test', access_token: 'valid_token')
    ENV['ALLOWED_ORIGINS'] = 'https://example.com,https://test.com'
  end

  test "show returns status for paid invoice" do
    result = Struct.new(:status_code_success, :paid?, :status).new(true, true, 'paid')
    EisBilling::GetReservedDomainInvoiceStatus.stub_any_instance(:call, result) do
      get api_v1_business_registry_status_url, headers: { 
        'Authorization' => 'Bearer valid_token',
        'Origin' => 'https://example.com'
      }

      assert_response :success
      assert_equal 'https://example.com', response.headers['Access-Control-Allow-Origin']
      response_body = JSON.parse(response.body)
      assert_equal 'paid', response_body['invoice_status']
      assert_equal 'example.test', response_body['reserved_domain']
      assert_not_nil response_body['password']
    end
  end

  test "show returns status for unpaid invoice" do
    result = Struct.new(:status_code_success, :paid?, :status).new(true, false, 'unpaid')
    EisBilling::GetReservedDomainInvoiceStatus.stub_any_instance(:call, result) do
      get api_v1_business_registry_status_url, headers: { 
        'Authorization' => 'Bearer valid_token',
        'Origin' => 'https://example.com'
      }

      assert_response :success
      assert_equal 'https://example.com', response.headers['Access-Control-Allow-Origin']
      assert_equal({ 'invoice_status' => 'unpaid' }, JSON.parse(response.body))
    end
  end

  test "show returns error when failed to get domain status" do
    result = Struct.new(:status_code_success, :details).new(false, 'Error details')
    EisBilling::GetReservedDomainInvoiceStatus.stub_any_instance(:call, result) do
      get api_v1_business_registry_status_url, headers: { 
        'Authorization' => 'Bearer valid_token',
        'Origin' => 'https://example.com'
      }

      assert_response :unprocessable_entity
      assert_equal({ 'error' => 'Failed to get domain status', 'details' => 'Error details' }, JSON.parse(response.body))
    end
  end

  test "show returns error for invalid token" do
    get api_v1_business_registry_status_url, headers: { 
      'Authorization' => 'Bearer invalid_token',
      'Origin' => 'https://example.com'
    }

    assert_response :unauthorized
    assert_equal({ 'error' => 'Invalid token' }, JSON.parse(response.body))
  end

  test "show returns error for expired token" do
    @reserved_domain_status.update(token_created_at: 31.days.ago)

    get api_v1_business_registry_status_url, headers: { 
      'Authorization' => 'Bearer valid_token',
      'Origin' => 'https://example.com'
    }

    assert_response :unauthorized
    assert_equal({ 'error' => 'Token expired. Please refresh the token. TODO: provide endpoint' }, JSON.parse(response.body))
  end

  test "show returns error for unauthorized origin" do
    get api_v1_business_registry_status_url, headers: { 
      'Authorization' => 'Bearer valid_token',
      'Origin' => 'https://unauthorized.com'
    }

    assert_response :unauthorized
    assert_equal({ 'error' => 'Unauthorized origin' }, JSON.parse(response.body))
  end
end