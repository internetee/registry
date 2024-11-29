require 'test_helper'

class ReserveDomainInvoiceTest < ActiveSupport::TestCase
  TEST_USER_UNIQUE_ID = 'test123'
  INVOICE_NUMBER = '12345'
  
  def setup
    @domain_names = ['example1.test', 'example2.test']
    
    stub_invoice_number_request
    stub_add_deposits_request
    stub_reserved_domains_invoice_status
    
    # Mock generate_unique_id to return consistent value
    ReserveDomainInvoice.singleton_class.class_eval do
      alias_method :original_generate_unique_id, :generate_unique_id
      define_method(:generate_unique_id) { TEST_USER_UNIQUE_ID }
    end
  end

  def teardown
    # Restore original method
    ReserveDomainInvoice.singleton_class.class_eval do
      alias_method :generate_unique_id, :original_generate_unique_id
      remove_method :original_generate_unique_id
    end
  end

  test "normalizes domain names" do
    mixed_case_domains = ['EXAMPLE1.TEST', ' example2.test ']
    result = ReserveDomainInvoice.create_list_of_domains(
      mixed_case_domains
    )
    
    invoice = ReserveDomainInvoice.last
    assert_equal ['example1.test', 'example2.test'], invoice.domain_names
  end

  test "filters out unavailable domains" do
    domain_names = ['domain-one.test', 'domain-two.test']
    ReservedDomain.create!(name: domain_names.first)
    result = ReserveDomainInvoice.create_list_of_domains(domain_names)
    
    invoice = ReserveDomainInvoice.last
    assert_equal [domain_names.last], invoice.domain_names
  end

  test "creates reserved domains after payment" do
    invoice = ReserveDomainInvoice.create(invoice_number: '12345', domain_names: @domain_names, metainfo: TEST_USER_UNIQUE_ID)
    
    assert_difference 'ReservedDomain.count', 2 do
      invoice.create_reserved_domains
    end
  end

  test "builds correct output for reserved domains" do
    invoice = ReserveDomainInvoice.create(invoice_number: '12345', domain_names: @domain_names, metainfo: TEST_USER_UNIQUE_ID)
    ReservedDomain.create(name: @domain_names.first, password: 'test123')
    
    output = invoice.build_reserved_domains_output
    assert_equal @domain_names.count, output.length
    assert_equal 'test123', output.first[@domain_names.first]
  end

  test "handles intersecting domains" do
    existing_invoice = ReserveDomainInvoice.create(
      invoice_number: '12345',
      domain_names: [@domain_names.first],
      status: :pending,
      metainfo: TEST_USER_UNIQUE_ID
    )

    assert ReserveDomainInvoice.are_domains_intersect?(@domain_names)
    assert_equal '12345', ReserveDomainInvoice.get_invoice_number_from_intersecting_invoice(@domain_names)
  end

  test "checks if any intersecting invoice is paid" do
    ReserveDomainInvoice.create(
      invoice_number: '12345',
      domain_names: [@domain_names.first],
      status: :paid,
      metainfo: TEST_USER_UNIQUE_ID
    )

    assert ReserveDomainInvoice.is_any_intersecting_invoice_paid?(@domain_names)
  end

  test "cancels intersecting invoices" do
    invoice1 = ReserveDomainInvoice.create(
      invoice_number: '12345',
      domain_names: [@domain_names.first],
      status: :pending,
      metainfo: TEST_USER_UNIQUE_ID
    )
    
    invoice2 = ReserveDomainInvoice.create(
      invoice_number: '12346',
      domain_names: [@domain_names.first],
      status: :pending,
      metainfo: TEST_USER_UNIQUE_ID
    )

    ReserveDomainInvoice.cancel_intersecting_invoices(@domain_names)
    
    assert invoice1.reload.cancelled?
    assert invoice2.reload.cancelled?
  end

  test "checks state of intersecting invoices" do
    invoice = ReserveDomainInvoice.create(
      invoice_number: '12345',
      domain_names: [@domain_names.first],
      status: :pending,
      metainfo: TEST_USER_UNIQUE_ID
    )

    # Mock invoice_state to return paid status
    mock_result = Struct.new(:paid?, :status).new(true, 'paid')
    invoice.stub :invoice_state, mock_result do
      ReserveDomainInvoice.check_state_of_intersecting_invoices(@domain_names)
      
      assert invoice.reload.paid?
      # Verify that reserved domains were created
      assert_not_nil ReservedDomain.find_by(name: @domain_names.first)
    end
  end

  test "creates list of domains with existing invoice number" do
    existing_invoice = ReserveDomainInvoice.create(
      invoice_number: '12345',
      domain_names: [@domain_names.first],
      status: :pending,
      metainfo: TEST_USER_UNIQUE_ID
    )

    stub_request(:get, "https://eis_billing_system:3000/api/v1/invoice/reserved_domains_invoice_statuses?invoice_number=#{INVOICE_NUMBER}&user_unique_id=#{TEST_USER_UNIQUE_ID}")
      .to_return(status: 200, body: { invoice_status: 'pending' }.to_json, headers: {})

    result = ReserveDomainInvoice.create_list_of_domains(@domain_names)
    
    assert result.status_code_success
    assert_equal 12345, result.invoice_number
  end

  test "returns error when intersecting invoice is paid" do
    ReserveDomainInvoice.create(
      invoice_number: '12345',
      domain_names: [@domain_names.first],
      status: :paid,
      metainfo: TEST_USER_UNIQUE_ID
    )

    result = ReserveDomainInvoice.create_list_of_domains(@domain_names)
    
    refute result.status_code_success
    assert_equal 'Some intersecting invoices are paid', result.details
  end

  test "generates unique user id for new invoice" do
    result = ReserveDomainInvoice.create_list_of_domains(@domain_names)
    
    assert result.status_code_success
    assert_not_nil result.user_unique_id
    assert_equal TEST_USER_UNIQUE_ID.length, result.user_unique_id.length
  end

  test "returns error when no domains are available" do
    BusinessRegistry::DomainAvailabilityCheckerService.stub :filter_available, [] do
      result = ReserveDomainInvoice.create_list_of_domains(@domain_names)
      
      refute result.status_code_success
      assert_equal 'No available domains', result.details
    end
  end

  test "should handle expired reserved domains in domain filtering" do
    expired_domain = ReservedDomain.create!(
      name: @domain_names.first,
      expire_at: 1.day.ago
    )
    
    result = ReserveDomainInvoice.create_list_of_domains(@domain_names)
    
    assert result.status_code_success
    assert_includes result.reserved_domain_names, @domain_names.second
    assert_nil ReservedDomain.find_by(id: expired_domain.id)
  end

  test "should not affect non-expired reserved domains in domain filtering" do
    active_domain = ReservedDomain.create!(
      name: @domain_names.first,
      expire_at: 1.day.from_now
    )
    
    result = ReserveDomainInvoice.create_list_of_domains(@domain_names)
    
    assert result.status_code_success
    refute_includes result.reserved_domain_names, @domain_names.first
    assert ReservedDomain.exists?(id: active_domain.id)
  end

  test "should not affect permanent reserved domains in domain filtering" do
    permanent_domain = ReservedDomain.create!(
      name: @domain_names.first,
      expire_at: nil
    )
    
    result = ReserveDomainInvoice.create_list_of_domains(@domain_names)
    
    assert result.status_code_success
    puts result
    refute_includes result.reserved_domain_names, @domain_names.first
    assert ReservedDomain.exists?(id: permanent_domain.id)
  end

  private

  def stub_invoice_number_request
    stub_request(:post, "https://eis_billing_system:3000/api/v1/invoice_generator/invoice_number_generator")
      .to_return(status: 200, body: { invoice_number: INVOICE_NUMBER }.to_json, headers: {})
  end

  def stub_add_deposits_request
    stub_request(:post, "https://eis_billing_system:3000/api/v1/invoice_generator/invoice_generator")
      .to_return(status: 201, body: { everypay_link: 'https://pay.test' }.to_json)
  end

  def stub_reserved_domains_invoice_status
    stub_request(:get, "https://eis_billing_system:3000/api/v1/invoice/reserved_domains_invoice_statuses?invoice_number=#{INVOICE_NUMBER}&user_unique_id=#{TEST_USER_UNIQUE_ID}")
      .to_return(status: 200, body: { invoice_status: 'paid' }.to_json, headers: {})
  end
end
