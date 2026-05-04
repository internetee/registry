require 'test_helper'

class Api::V1::BusinessRegistry::ReservedDomainsInvoicePdfControllerTest < ActionDispatch::IntegrationTest
  def setup
    @domain_names = ['example1.test', 'example2.test']
    @invoice = ReserveDomainInvoice.create(invoice_number: '12345', domain_names: @domain_names, metainfo: SecureRandom.uuid[0..7])
    @allowed_origins = ['http://example.com', 'https://test.com']
    ENV['ALLOWED_ORIGINS'] = @allowed_origins.join(',')
    @valid_ip = '127.0.0.1'
    ENV['auction_api_allowed_ips'] = @valid_ip
    @valid_token = 'valid_test_token'
    ENV['business_registry_api_tokens'] = @valid_token

    @auth_headers = {
      'Origin' => @allowed_origins.first,
      'REMOTE_ADDR' => @valid_ip,
      'Authorization' => "Bearer #{@valid_token}"
    }

    stub_reserved_domains_invoice_status
  end

  test 'returns pdf when invoice is paid' do
    stub_billing_request(
      status: 200,
      body: {
        message: 'Payment received',
        invoice_status: 'paid',
        invoice_number: @invoice.invoice_number
      },
      user_unique_id: @invoice.metainfo
    )

    ReserveDomainInvoice.stub_any_instance(:as_pdf, '%PDF-1.4 fake') do
      get api_v1_business_registry_reserved_domains_invoice_pdf_path(invoice_number: @invoice.invoice_number,
                                                                     user_unique_id: @invoice.metainfo),
          headers: @auth_headers
    end

    assert_response :success
    assert_equal 'application/pdf', response.headers['Content-Type']
    assert_match(/attachment; filename="invoice-12345\.pdf"/, response.headers['Content-Disposition'])
    assert_includes response.body, '%PDF-1.4'
  end

  test 'returns 502 when billing service is unreachable' do
    stub_request(:get, "https://eis_billing_system:3000/api/v1/invoice/reserved_domains_invoice_statuses?invoice_number=#{@invoice.invoice_number}&user_unique_id=#{@invoice.metainfo}")
      .to_raise(SocketError.new('getaddrinfo: Name or service not known'))

    get api_v1_business_registry_reserved_domains_invoice_pdf_path(invoice_number: @invoice.invoice_number,
                                                                   user_unique_id: @invoice.metainfo),
        headers: @auth_headers

    assert_response :bad_gateway
    json_response = JSON.parse(response.body)
    assert_equal 'Billing service unavailable', json_response['error']
    assert_equal 'SocketError', json_response.dig('details', 'reason')
  end

  test 'returns 401 when authorization token is missing' do
    get api_v1_business_registry_reserved_domains_invoice_pdf_path(invoice_number: @invoice.invoice_number,
                                                                   user_unique_id: @invoice.metainfo)

    assert_response :unauthorized
    assert_equal 'Unauthorized', JSON.parse(response.body)['error']
  end

  test 'returns 401 when authorization token is invalid' do
    get api_v1_business_registry_reserved_domains_invoice_pdf_path(invoice_number: @invoice.invoice_number,
                                                                   user_unique_id: @invoice.metainfo),
        headers: @auth_headers.merge('Authorization' => 'Bearer wrong_token')

    assert_response :unauthorized
  end

  test 'returns 404 when invoice does not exist' do
    get api_v1_business_registry_reserved_domains_invoice_pdf_path(invoice_number: 'does-not-exist',
                                                                   user_unique_id: 'nope'),
        headers: @auth_headers

    assert_response :not_found
  end

  test 'returns 404 when invoice_number matches but user_unique_id does not' do
    get api_v1_business_registry_reserved_domains_invoice_pdf_path(invoice_number: @invoice.invoice_number,
                                                                   user_unique_id: 'wrong-uid'),
        headers: @auth_headers

    assert_response :not_found
  end

  test 'returns error when invoice is not paid' do
    stub_billing_request(
      status: 200,
      body: {
        message: 'Payment pending',
        invoice_status: 'unpaid',
        invoice_number: @invoice.invoice_number
      },
      user_unique_id: @invoice.metainfo
    )

    get api_v1_business_registry_reserved_domains_invoice_pdf_path(invoice_number: @invoice.invoice_number,
                                                                   user_unique_id: @invoice.metainfo),
        headers: @auth_headers

    assert_response :unprocessable_entity
    json_response = JSON.parse(response.body)
    assert_equal 'Invoice is not paid', json_response['error']
    assert_equal 'unpaid', json_response.dig('details', 'status')
    assert_equal 'Payment pending', json_response.dig('details', 'message')
  end

  private

  def stub_billing_request(status:, body:, user_unique_id: nil)
    stub_request(:get, "https://eis_billing_system:3000/api/v1/invoice/reserved_domains_invoice_statuses?invoice_number=#{@invoice.invoice_number}&user_unique_id=#{user_unique_id}")
      .with(
        headers: EisBilling::Base.headers
      )
      .to_return(
        status: status,
        body: body.to_json,
        headers: { 'Content-Type' => 'application/json' }
      )
  end

  def stub_reserved_domains_invoice_status
    stub_request(:get, "https://eis_billing_system:3000/api/v1/invoice/reserved_domains_invoice_statuses?invoice_number=#{@invoice.invoice_number}&user_unique_id=#{@invoice.metainfo}")
      .with(
        headers: EisBilling::Base.headers
      )
      .to_return(status: 200, body: {}.to_json, headers: { 'Content-Type' => 'application/json' })
  end
end

