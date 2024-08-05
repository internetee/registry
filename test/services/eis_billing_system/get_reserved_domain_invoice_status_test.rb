require 'test_helper'
require 'minitest/autorun'

class EisBilling::GetReservedDomainInvoiceStatusTest < ActiveSupport::TestCase
  def setup
    @domain_name = 'example.com'
    @token = 'test_token'
    @service = EisBilling::GetReservedDomainInvoiceStatus.new(domain_name: @domain_name, token: @token)
  end

  test 'initialization sets domain_name and token' do
    assert_equal @domain_name, @service.domain_name
    assert_equal @token, @service.token
  end

  test 'call method sends GET request and processes response' do
    mock_response = Struct.new(:body, :code).new(
      { message: 'Success', invoice_status: 'paid', invoice_number: '12345' }.to_json,
      '200'
    )

    Net::HTTP.stub_any_instance(:get, mock_response) do
      result = @service.call

      assert result.status_code_success
      assert result.paid?
      assert_equal 'paid', result.status
      assert_equal 'Success', result.message
      assert_equal '12345', result.invoice_number
    end
  end

  test 'call method handles unpaid status' do
    mock_response = Struct.new(:body, :code).new(
      { message: 'Unpaid', invoice_status: 'unpaid', invoice_number: '12345' }.to_json,
      '200'
    )

    Net::HTTP.stub_any_instance(:get, mock_response) do
      result = @service.call

      assert result.status_code_success
      refute result.paid?
      assert_equal 'unpaid', result.status
      assert_equal 'Unpaid', result.message
      assert_equal '12345', result.invoice_number
    end
  end

  test 'call method handles error response' do
    mock_response = Struct.new(:body, :code).new(
      { message: 'Error', invoice_status: 'error' }.to_json,
      '400'
    )

    Net::HTTP.stub_any_instance(:get, mock_response) do
      result = @service.call

      refute result.status_code_success
      refute result.paid?
      assert_equal 'error', result.status
      assert_equal 'Error', result.message
    end
  end

  test 'reserved_domain_invoice_statuses_url generates correct URL' do
    expected_url = "http://eis_billing_system:3000/api/v1/invoice/reserved_domain_invoice_statuses?domain_name=#{@domain_name}&token=#{@token}"
    assert_equal expected_url, @service.reserved_domain_invoice_statuses_url
  end

  test 'class method call creates instance and calls instance method' do
    mock_response = Struct.new(:body, :code).new(
      { message: 'Success', invoice_status: 'paid', invoice_number: '12345' }.to_json,
      '200'
    )

    Net::HTTP.stub_any_instance(:get, mock_response) do
      result = EisBilling::GetReservedDomainInvoiceStatus.call(domain_name: @domain_name, token: @token)

      assert result.status_code_success
      assert result.paid?
      assert_equal 'paid', result.status
      assert_equal 'Success', result.message
      assert_equal '12345', result.invoice_number
    end
  end
end