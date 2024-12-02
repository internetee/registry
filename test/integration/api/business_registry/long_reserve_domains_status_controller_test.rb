require 'test_helper'

class Api::V1::BusinessRegistry::LongReserveDomainsStatusControllerTest < ActionDispatch::IntegrationTest
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

  test "shows paid status and creates reserved domains" do
    stub_billing_request(
      status: 200,
      body: {
        message: 'Payment received',
        invoice_status: 'paid',
        invoice_number: @invoice.invoice_number,
        reserved_domain_names: @invoice.domain_names
      },
      user_unique_id: @invoice.metainfo
    )

    get api_v1_business_registry_long_reserve_domains_status_path(invoice_number: @invoice.invoice_number, user_unique_id: @invoice.metainfo),
        headers: @auth_headers

    assert_response :success
    json_response = JSON.parse(response.body)
    
    assert_equal 'paid', json_response['status']
    assert_equal 'Payment received', json_response['message']
    assert_not_nil json_response['reserved_domains']
  end

  test "shows unpaid status" do
    stub_billing_request(
      status: 200,
      body: {
        message: 'Payment pending',
        invoice_status: 'unpaid',
        invoice_number: @invoice.invoice_number
      },
      user_unique_id: @invoice.metainfo
    )

    get api_v1_business_registry_long_reserve_domains_status_path(invoice_number: @invoice.invoice_number, user_unique_id: @invoice.metainfo),
        headers: @auth_headers

    assert_response :success
    json_response = JSON.parse(response.body)
    
    assert_equal 'unpaid', json_response['status']
    assert_equal 'Payment pending', json_response['message']
    assert_equal @domain_names, json_response['names']
  end

  test "returns 404 for non-existent invoice" do
    get api_v1_business_registry_long_reserve_domains_status_path('nonexistent'),
        headers: @auth_headers

    assert_response :not_found
  end

  test "handles error response from billing system" do
    stub_billing_request(
      status: 400,
      body: {
        message: 'Error occurred',
        invoice_status: 'error',
        invoice_number: @invoice.invoice_number
      },
      user_unique_id: @invoice.metainfo
    )

    get api_v1_business_registry_long_reserve_domains_status_path(invoice_number: @invoice.invoice_number, user_unique_id: @invoice.metainfo),
        headers: @auth_headers

    assert_response :success
    json_response = JSON.parse(response.body)
    assert_equal 'error', json_response['status']
    assert_equal 'Error occurred', json_response['message']
  end

  test "shows paid status with expire_at for reserved domains" do
    stub_billing_request(
      status: 200,
      body: {
        message: 'Payment received',
        invoice_status: 'paid',
        invoice_number: @invoice.invoice_number,
        reserved_domain_names: @invoice.domain_names
      },
      user_unique_id: @invoice.metainfo
    )

    get api_v1_business_registry_long_reserve_domains_status_path(
      invoice_number: @invoice.invoice_number, 
      user_unique_id: @invoice.metainfo
    ),
    headers: @auth_headers

    assert_response :success
    json_response = JSON.parse(response.body)
    
    assert_equal 'paid', json_response['status']
    assert_equal 'Payment received', json_response['message']
    
    # Проверяем структуру reserved_domains
    reserved_domain = json_response['reserved_domains'].first
    assert_not_nil reserved_domain['name']
    assert_not_nil reserved_domain['password']
    assert_not_nil reserved_domain['expire_at']
    
    # Проверяем, что expire_at установлен на 1 год
    expire_at = Time.parse(reserved_domain['expire_at'])
    assert_in_delta Time.current + ReservedDomain::PAID_RESERVATION_EXPIRY, expire_at, 5.seconds
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
