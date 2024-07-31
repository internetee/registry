require 'test_helper'
require 'webmock/minitest'

class GetInvoiceNumberTest < ActionDispatch::IntegrationTest
  setup do
    @original_base_url = ENV['eis_billing_system_base_url']
    @original_billing_secret = ENV['billing_secret']
    ENV['eis_billing_system_base_url'] = 'https://test-billing.example.com'
    ENV['billing_secret'] = 'test_secret'
  end

  teardown do
    ENV['eis_billing_system_base_url'] = @original_base_url
    ENV['billing_secret'] = @original_billing_secret
  end

  test "call returns expected result" do
    expected_response = '{"invoice_number": "12345"}'
    
    stub_request(:post, "https://test-billing.example.com/api/v1/invoice_generator/invoice_number_generator")
      .to_return(status: 200, body: expected_response, headers: { 'Content-Type' => 'application/json' })

    result = EisBilling::GetInvoiceNumber.call

    assert_equal expected_response, result.body
    assert_equal '200', result.code

    assert_requested :post, "https://test-billing.example.com/api/v1/invoice_generator/invoice_number_generator", {
      headers: {
        'Content-Type' => 'application/json',
        'Authorization' => /^Bearer .+$/
      },
      body: nil
    }
  end

  test "invoice_number_generator_url returns correct URL" do
    expected_url = "https://test-billing.example.com/api/v1/invoice_generator/invoice_number_generator"
    assert_equal expected_url, EisBilling::GetInvoiceNumber.send(:invoice_number_generator_url)
  end

  test "headers from base class are correct" do
    EisBilling::Base.stub :generate_token, 'test_token' do
      expected_headers = {
        'Authorization' => 'Bearer test_token',
        'Content-Type' => 'application/json',
      }
      assert_equal expected_headers, EisBilling::Base.headers
    end
  end
end
