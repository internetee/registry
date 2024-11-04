require 'test_helper'

class ReserveDomainInvoiceTest < ActiveSupport::TestCase
  def setup
    @domain_names = ['example1.test', 'example2.test']
    @success_url = 'https://success.test'
    @failed_url = 'https://failed.test'
    
    stub_invoice_number_request
    stub_add_deposits_request
    stub_oneoff_request
  end

  test "creates list of domains successfully" do
    result = ReserveDomainInvoice.create_list_of_domains(
      @domain_names, 
      @success_url, 
      @failed_url
    )
    
    assert result.status_code_success
    assert_not_nil result.oneoff_payment_link
    assert_not_nil result.invoice_number
    
    invoice = ReserveDomainInvoice.last
    assert_equal @success_url, invoice.success_business_registry_customer_url
    assert_equal @failed_url, invoice.failed_business_registry_customer_url
  end

  test "normalizes domain names" do
    mixed_case_domains = ['EXAMPLE1.TEST', ' example2.test ']
    result = ReserveDomainInvoice.create_list_of_domains(
      mixed_case_domains,
      @success_url,
      @failed_url
    )
    
    invoice = ReserveDomainInvoice.last
    assert_equal ['example1.test', 'example2.test'], invoice.domain_names
  end

  test "handles oneoff service failure" do
    stub_request(:post, "https://eis_billing_system:3000/api/v1/invoice_generator/oneoff")
      .to_return(status: 422, body: { error: 'Payment failed' }.to_json)

    result = ReserveDomainInvoice.create_list_of_domains(
      @domain_names,
      @success_url,
      @failed_url
    )
    
    assert_equal 'Payment failed', result.details['error']
  end

  test "filters out unavailable domains" do
    ReservedDomain.create!(name: @domain_names.first)
    result = ReserveDomainInvoice.create_list_of_domains(@domain_names, @success_url, @failed_url)
    
    invoice = ReserveDomainInvoice.last
    assert_equal [@domain_names.last], invoice.domain_names
  end

  test "creates reserved domains after payment" do
    invoice = ReserveDomainInvoice.create(invoice_number: '12345', domain_names: @domain_names)
    
    assert_difference 'ReservedDomain.count', 2 do
      invoice.create_reserved_domains
    end
  end

  test "builds correct output for reserved domains" do
    invoice = ReserveDomainInvoice.create(invoice_number: '12345', domain_names: @domain_names)
    ReservedDomain.create(name: @domain_names.first, password: 'test123')
    
    output = invoice.build_reserved_domains_output
    assert_equal @domain_names.count, output.length
    assert_equal 'test123', output.first[@domain_names.first]
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
      .to_return(
        status: 200, 
        body: { oneoff_redirect_link: 'https://payment.test' }.to_json,
        headers: { 'Content-Type': 'application/json' }
      )
  end
end
