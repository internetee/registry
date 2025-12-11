require 'test_helper'

class EisBilling::GetReservedDomainsInvoiceStatusTest < ActiveSupport::TestCase
  def setup
    @invoice_number = '12345'
    @service = EisBilling::GetReservedDomainsInvoiceStatus.new(invoice_number: @invoice_number)
  end

  test "initialization sets invoice number" do
    assert_equal @invoice_number, @service.invoice_number
  end

  test "call method sends GET request and processes paid response" do
    stub_billing_request(
      status: 200,
      body: {
        message: 'Payment received',
        invoice_status: 'paid',
        invoice_number: @invoice_number,
        details: { 'some' => 'details' }
      }
    )

    result = @service.call

    assert result.status_code_success
    assert result.paid?
    assert_equal 'paid', result.status
    assert_equal 'Payment received', result.message
    assert_equal @invoice_number, result.invoice_number
    assert_equal({ 'some' => 'details' }, result.details)
  end

  test "call method handles unpaid status" do
    stub_billing_request(
      status: 200,
      body: {
        message: 'Payment pending',
        invoice_status: 'unpaid',
        invoice_number: @invoice_number
      }
    )

    result = @service.call

    assert result.status_code_success
    refute result.paid?
    assert_equal 'unpaid', result.status
    assert_equal 'Payment pending', result.message
  end

  test "call method handles error response" do
    stub_billing_request(
      status: 400,
      body: {
        message: 'Error occurred',
        invoice_status: 'error',
        details: { 'error' => 'Some error' }
      }
    )

    result = @service.call

    refute result.status_code_success
    refute result.paid?
    assert_equal 'error', result.status
    assert_equal 'Error occurred', result.message
    assert_equal({ 'error' => 'Some error' }, result.details)
  end

  test "class method call creates instance and calls instance method" do
    stub_request(:get, "https://eis_billing_system:3000/api/v1/invoice/reserved_domains_invoice_statuses?invoice_number=#{@invoice_number}&user_unique_id=user123")
        .to_return(status: 200, body: { invoice_status: 'paid' }.to_json, headers: {})

    result = EisBilling::GetReservedDomainsInvoiceStatus.call(invoice_number: @invoice_number, user_unique_id: 'user123')

    assert result.status_code_success
    assert result.paid?
    assert_equal 'paid', result.status
  end

  private

  def stub_billing_request(status:, body:)
    stub_request(:get, "https://eis_billing_system:3000/api/v1/invoice/reserved_domains_invoice_statuses?invoice_number=#{@invoice_number}&user_unique_id=")
      .with(
        headers: EisBilling::Base.headers
      )
      .to_return(
        status: status,
        body: body.to_json,
        headers: { 'Content-Type' => 'application/json' }
      )
  end
end
