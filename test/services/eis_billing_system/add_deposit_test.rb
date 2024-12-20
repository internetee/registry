require 'test_helper'
require 'webmock/minitest'

class AddDepositsTest < ActiveSupport::TestCase
  setup do
    @invoice = Struct.new(:total, :number, :buyer_name, :buyer_email, :description, :initiator, :reference_no, :reserved_domain_names, :token).new(
      100.50, '12345', 'John Doe', 'john@example.com', 'Test invoice', 'test_initiator', 'REF001', 'example.com', 'test_token'
    )
  end

  test "parse_invoice returns correct data" do
    add_deposits = EisBilling::AddDeposits.new(@invoice)
    parsed_data = add_deposits.send(:parse_invoice)

    assert_equal '100.5', parsed_data[:transaction_amount]
    assert_equal '12345', parsed_data[:order_reference]
    assert_equal 'John Doe', parsed_data[:customer_name]
    assert_equal 'john@example.com', parsed_data[:customer_email]
    assert_equal 'Test invoice', parsed_data[:custom_field1]
    assert_equal 'test_initiator', parsed_data[:custom_field2]
    assert_equal '12345', parsed_data[:invoice_number]
    assert_equal 'REF001', parsed_data[:reference_number]
    assert_equal 'example.com', parsed_data[:reserved_domain_names]
  end

  test "call sends correct request and returns response" do
    expected_response = '{"status": "success"}'
    
    stub_request(:post, "https://eis_billing_system:3000/api/v1/invoice_generator/invoice_generator")
      .with(
        body: {
          transaction_amount: "100.5",
          order_reference: "12345",
          customer_name: "John Doe",
          customer_email: "john@example.com",
          custom_field1: "Test invoice",
          custom_field2: "test_initiator",
          invoice_number: "12345",
          reference_number: "REF001",
          reserved_domain_names: "example.com",
        }.to_json,
      )
      .to_return(status: 200, body: expected_response, headers: { 'Content-Type' => 'application/json' })

    add_deposits = EisBilling::AddDeposits.new(@invoice)
    result = add_deposits.call

    assert_equal expected_response, result.body
    assert_equal '200', result.code

    assert_requested :post, "https://eis_billing_system:3000/api/v1/invoice_generator/invoice_generator", times: 1
  end

  test "invoice_generator_url returns correct URL" do
    add_deposits = EisBilling::AddDeposits.new(@invoice)
    expected_url = "http://eis_billing_system:3000/api/v1/invoice_generator/invoice_generator"
    assert_equal expected_url, add_deposits.send(:invoice_generator_url)
  end
end