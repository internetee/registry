require 'test_helper'
require 'webmock/minitest'

class EisBilling::OneoffServiceTest < ActiveSupport::TestCase
  def setup
    @invoice_number = '12345'
    @customer_url = 'https://example.com/success'
    @amount = 100.50
    @service = EisBilling::OneoffService.new(
      invoice_number: @invoice_number,
      customer_url: @customer_url,
      amount: @amount
    )
  end

  test "initialization sets attributes correctly" do
    assert_equal @invoice_number, @service.invoice_number
    assert_equal @customer_url, @service.customer_url
    assert_equal @amount, @service.amount
  end

  test "call method sends POST request with correct parameters" do
    expected_response = { everypay_link: 'https://pay.example.com/12345' }
    
    stub_request(:post, "https://eis_billing_system:3000/api/v1/invoice_generator/oneoff")
      .with(
        body: {
          invoice_number: @invoice_number,
          customer_url: @customer_url,
          amount: @amount
        }.to_json,
        headers: {
          'Content-Type' => 'application/json',
          'Authorization' => /^Bearer .+$/
        }
      )
      .to_return(status: 200, body: expected_response.to_json, headers: { 'Content-Type' => 'application/json' })

    response = @service.call
    
    assert_equal 200, response.code.to_i
    assert_equal expected_response.to_json, response.body
  end

  test "class method call creates instance and calls instance method" do
    expected_response = { everypay_link: 'https://pay.example.com/12345' }
    
    stub_request(:post, "https://eis_billing_system:3000/api/v1/invoice_generator/oneoff")
      .to_return(status: 200, body: expected_response.to_json, headers: { 'Content-Type' => 'application/json' })

    response = EisBilling::OneoffService.call(
      invoice_number: @invoice_number,
      customer_url: @customer_url,
      amount: @amount
    )

    assert_equal 200, response.code.to_i
    assert_equal expected_response.to_json, response.body
  end

  test "handles error response" do
    error_response = { error: 'Invalid parameters' }
    
    stub_request(:post, "https://eis_billing_system:3000/api/v1/invoice_generator/oneoff")
      .to_return(status: 422, body: error_response.to_json, headers: { 'Content-Type' => 'application/json' })

    response = @service.call
    
    assert_equal 422, response.code.to_i
    assert_equal error_response.to_json, response.body
  end

  test "sends request with nil amount" do
    service = EisBilling::OneoffService.new(
      invoice_number: @invoice_number,
      customer_url: @customer_url,
      amount: nil
    )

    stub_request(:post, "https://eis_billing_system:3000/api/v1/invoice_generator/oneoff")
      .with(
        body: {
          invoice_number: @invoice_number,
          customer_url: @customer_url,
          amount: nil
        }.to_json,
        headers: {
          'Content-Type' => 'application/json',
          'Authorization' => /^Bearer .+$/
        }
      )
      .to_return(status: 200, body: '{}', headers: { 'Content-Type' => 'application/json' })

    response = service.call
    assert_equal 200, response.code.to_i
  end
end
