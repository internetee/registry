require 'test_helper'
require 'webmock/minitest'

class GetInvoiceNumberTest < ActionDispatch::IntegrationTest
  test "call returns expected result" do
    expected_response = '{"invoice_number": "12345"}'
    
    stub_request(:post, "https://eis_billing_system:3000/api/v1/invoice_generator/invoice_number_generator")
      .to_return(status: 200, body: expected_response, headers: { 'Content-Type' => 'application/json' })

    result = EisBilling::GetInvoiceNumber.call

    assert_equal expected_response, result.body
    assert_equal '200', result.code

    assert_requested :post, "https://eis_billing_system:3000/api/v1/invoice_generator/invoice_number_generator", {
      headers: {
        'Content-Type' => 'application/json',
        'Authorization' => /^Bearer .+$/
      },
      body: nil
    }
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
