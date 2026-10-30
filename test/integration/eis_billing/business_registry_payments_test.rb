require 'test_helper'

class EisBilling::BusinessRegistryPaymentsTest < ApplicationIntegrationTest
  setup do
    @invoice = ReserveDomainInvoice.create!(invoice_number: '777001',
                                            domain_names: ['bank-transfer.test'],
                                            metainfo: 'uid-bank',
                                            reference_no: '7770011',
                                            due_date: Date.new(2026, 11, 15))
  end

  test 'reserves domains and marks invoice paid' do
    BusinessRegistry::DomainAvailabilityCheckerService.stub :filter_available, ['bank-transfer.test'] do
      put_payment reference_number: @invoice.reference_no
    end

    assert_response :ok
    assert_equal 'Payment processed', JSON.parse(response.body)['message']
    assert @invoice.reload.paid?

    reserved_domain = ReservedDomain.find_by(name: 'bank-transfer.test')
    assert reserved_domain.present?

    version = Version::ReservedDomainVersion.where(item_id: reserved_domain.id).last
    assert_equal 'eis_billing', version.source
    assert_equal 'paid_reservation', version.reason
    assert_equal 'EIS billing payment', version.whodunnit
  end

  test 'cancels pending invoices with intersecting domains' do
    intersecting_invoice = ReserveDomainInvoice.create!(invoice_number: '777002',
                                                        domain_names: ['bank-transfer.test'],
                                                        metainfo: 'uid-other')

    BusinessRegistry::DomainAvailabilityCheckerService.stub :filter_available, ['bank-transfer.test'] do
      put_payment reference_number: @invoice.reference_no
    end

    assert_response :ok
    assert intersecting_invoice.reload.cancelled?
  end

  test 'responds ok without reserving again when invoice is already paid' do
    @invoice.paid!

    assert_no_difference 'ReservedDomain.count' do
      put_payment reference_number: @invoice.reference_no
    end

    assert_response :ok
    assert_equal 'Invoice already paid', JSON.parse(response.body)['message']
  end

  test 'denies access without valid token' do
    put eis_billing_business_registry_payment_path, params: payment_params(reference_number: @invoice.reference_no),
                                                    headers: { 'Authorization' => 'Bearer invalid' },
                                                    as: :json

    assert_response :unauthorized
    assert @invoice.reload.pending?
  end

  test 'responds not found for unknown reference number' do
    put_payment reference_number: '0000000'

    assert_response :not_found
    assert_equal 'Invoice not found', JSON.parse(response.body)['message']
  end

  test 'does not match invoices without reference number when reference is missing' do
    legacy_invoice = ReserveDomainInvoice.create!(invoice_number: '777003',
                                                  domain_names: ['legacy-transfer.test'],
                                                  metainfo: 'legacy-uid')

    put_payment reference_number: nil

    assert_response :not_found
    assert legacy_invoice.reload.pending?
  end

  test 'rejects payment for cancelled invoice' do
    @invoice.cancelled!

    assert_no_difference 'ReservedDomain.count' do
      put_payment reference_number: @invoice.reference_no
    end

    assert_response :unprocessable_entity
    assert_equal 'Invoice is cancelled', JSON.parse(response.body)['message']
    assert @invoice.reload.cancelled?
  end

  test 'rejects payment when some domain is no longer available' do
    @invoice.update!(domain_names: ['bank-transfer.test', 'taken-transfer.test'])

    BusinessRegistry::DomainAvailabilityCheckerService.stub :filter_available, ['bank-transfer.test'] do
      assert_no_difference 'ReservedDomain.count' do
        put_payment reference_number: @invoice.reference_no
      end
    end

    assert_response :unprocessable_entity
    assert_equal 'Failed to reserve domains', JSON.parse(response.body)['message']
    assert @invoice.reload.cancelled?
  end

  private

  def put_payment(reference_number:)
    put eis_billing_business_registry_payment_path, params: payment_params(reference_number: reference_number),
                                                    headers: billing_headers,
                                                    as: :json
  end

  def payment_params(reference_number:)
    {
      reference_number: reference_number,
      invoice_number: @invoice.invoice_number,
      amount: '10.0',
      currency: 'EUR',
      paid_at: '2026-10-16'
    }
  end

  def billing_headers
    token = JWT.encode({ initiator: 'billing' }, ENV['billing_secret'], 'HS256')
    { 'Authorization' => "Bearer #{token}" }
  end
end
