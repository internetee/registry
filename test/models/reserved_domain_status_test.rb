require 'test_helper'

class ReservedDomainStatusTest < ActiveSupport::TestCase
  def setup
    ENV['eis_billing_system_base_url'] ||= 'https://eis_billing_system:3000'
    @reserved_domain_status = ReservedDomainStatus.new(name: 'example.test')
    stub_eis_billing_requests
  end

  test "should be valid with valid attributes" do
    assert @reserved_domain_status.valid?
  end

  test "should generate access_token on create" do
    @reserved_domain_status.save
    assert_not_nil @reserved_domain_status.access_token
  end

  test "should set token_created_at on create" do
    @reserved_domain_status.save
    assert_not_nil @reserved_domain_status.token_created_at
    assert_in_delta Time.current, @reserved_domain_status.token_created_at, 1.second
  end

  test "token should not be expired when newly created" do
    @reserved_domain_status.save
    assert_not @reserved_domain_status.token_expired?
  end

  test "token should be expired after 30 days" do
    @reserved_domain_status.save
    @reserved_domain_status.update_column(:token_created_at, 31.days.ago)
    assert @reserved_domain_status.token_expired?
  end

  test "refresh_token should update token and token_created_at" do
    @reserved_domain_status.save
    old_token = @reserved_domain_status.access_token
    old_created_at = @reserved_domain_status.token_created_at

    @reserved_domain_status.refresh_token

    assert_not_equal old_token, @reserved_domain_status.access_token
    assert_not_equal old_created_at, @reserved_domain_status.token_created_at
    assert_in_delta Time.current, @reserved_domain_status.token_created_at, 1.second
  end

  test "should have correct enum values for status" do
    assert_equal 0, ReservedDomainStatus.statuses[:pending]
    assert_equal 1, ReservedDomainStatus.statuses[:paid]
    assert_equal 2, ReservedDomainStatus.statuses[:canceled]
    assert_equal 3, ReservedDomainStatus.statuses[:failed]
  end

  test "reserve_domain should return true and set status to pending on success" do
    assert @reserved_domain_status.reserve_domain
    assert_equal "pending", @reserved_domain_status.status
    assert_not_nil @reserved_domain_status.linkpay
  end

  test "reserve_domain should return false and set status to failed on failure" do
    stub_add_deposits_request(status: 400, body: { error: "Some error" }.to_json)
    assert_not @reserved_domain_status.reserve_domain
    assert_equal "failed", @reserved_domain_status.status
    assert_nil @reserved_domain_status.linkpay
  end

  test "reserve_domain should add error message on failure" do
    stub_add_deposits_request(status: 400, body: { error: "Some error" }.to_json)
    @reserved_domain_status.reserve_domain
    assert_includes @reserved_domain_status.errors.full_messages.join, "Some error"
  end

  test "reservation_domain_price should return correct price" do
    assert_equal 124.00, @reserved_domain_status.send(:reservation_domain_price)
  end

  test "create_invoice should return correct structure" do
    @reserved_domain_status.save
    invoice = @reserved_domain_status.send(:create_invoice, 12345)
    assert_equal 124.00, invoice.total
    assert_equal 12345, invoice.number
    assert_nil invoice.buyer_name
    assert_nil invoice.buyer_email
    assert_equal 'description', invoice.description
    assert_equal 'business_registry', invoice.initiator
    assert_nil invoice.reference_no
    assert_equal 'example.test', invoice.reserved_domain_name
    assert_equal @reserved_domain_status.access_token, invoice.token
  end

  def test_create_reserved_domain_with_punycode_name
    reserved_domain = ReservedDomainStatus.create(name: 'xn--4ca7aey.test')
    assert reserved_domain.valid?
  end

  def test_create_reserved_domain_with_unicode_name
    reserved_domain = ReservedDomainStatus.create(name: 'õäöü.test')
    assert reserved_domain.valid?
  end

  def test_cannot_to_register_invalid_domain_format
    reserved_domain = ReservedDomainStatus.new(name: 'example')
    assert_not reserved_domain.valid?
  end

  private

  def stub_eis_billing_requests
    stub_invoice_number_request
    stub_add_deposits_request
  end

  def stub_invoice_number_request
    stub_request(:post, "https://eis_billing_system:3000/api/v1/invoice_generator/invoice_number_generator")
      .with(
        headers: {
          'Accept'=>'*/*',
          'Accept-Encoding'=>'gzip;q=1.0,deflate;q=0.6,identity;q=0.3',
          'Authorization'=>/Bearer .+/,
          'Content-Type'=>'application/json',
          'User-Agent'=>'Ruby'
        }
      )
      .to_return(status: 200, body: { invoice_number: '12345' }.to_json, headers: { 'Content-Type' => 'application/json' })
  end

  def stub_add_deposits_request(status: 201, body: { everypay_link: 'https://pay.example.com' }.to_json)
    stub_request(:post, "https://eis_billing_system:3000/api/v1/invoice_generator/invoice_generator")
      .with(
        headers: {
          'Accept'=>'*/*',
          'Accept-Encoding'=>'gzip;q=1.0,deflate;q=0.6,identity;q=0.3',
          'Authorization'=>/Bearer .+/,
          'Content-Type'=>'application/json',
          'User-Agent'=>'Ruby'
        }
      )
      .to_return(status: status, body: body, headers: { 'Content-Type' => 'application/json' })
  end

end