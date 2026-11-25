require 'test_helper'

class EisBilling::BusinessRegistryCallbackTest < ApplicationIntegrationTest
  test 'paid callback creates reserved domains with eis_billing audit' do
    invoice = ReserveDomainInvoice.create!(invoice_number: '555555',
                                           domain_names: ['paid-callback.test'],
                                           metainfo: 'uid-123')

    result = Struct.new(:code, :body).new('200', { 'custom_field_1' => 'uid-123' }.to_json)

    EisBilling::SendCallbackService.stub :call, result do
      BusinessRegistry::DomainAvailabilityCheckerService.stub :filter_available, ['paid-callback.test'] do
        get eis_billing_callback_path, params: { payment_reference: 'ref-1', order_reference: invoice.invoice_number }
      end
    end

    assert_response :ok
    assert_equal 'Callback received', JSON.parse(response.body)['message']

    reserved_domain = ReservedDomain.find_by(name: 'paid-callback.test')
    assert reserved_domain.present?

    version = Version::ReservedDomainVersion.where(item_id: reserved_domain.id).last
    assert_equal 'create', version.event
    assert_equal 'eis_billing', version.source
    assert_equal 'paid_reservation', version.reason
    assert_equal 'paid-callback.test', version.domain_name
    assert_equal 'EIS billing callback', version.whodunnit
  end

  test 'paid callback cancels pending invoices with intersecting domains' do
    invoice = ReserveDomainInvoice.create!(invoice_number: '555556',
                                           domain_names: ['shared-callback.test'],
                                           metainfo: 'uid-456')
    intersecting_invoice = ReserveDomainInvoice.create!(invoice_number: '555557',
                                                        domain_names: ['shared-callback.test', 'other-callback.test'],
                                                        metainfo: 'uid-789')

    result = Struct.new(:code, :body).new('200', { 'custom_field_1' => 'uid-456' }.to_json)

    EisBilling::SendCallbackService.stub :call, result do
      BusinessRegistry::DomainAvailabilityCheckerService.stub :filter_available, ['shared-callback.test'] do
        get eis_billing_callback_path, params: { payment_reference: 'ref-2', order_reference: invoice.invoice_number }
      end
    end

    assert_response :ok
    assert invoice.reload.paid?
    assert intersecting_invoice.reload.cancelled?
  end

  test 'paid callback does not reserve anything when some domain is unavailable' do
    invoice = ReserveDomainInvoice.create!(invoice_number: '555558',
                                           domain_names: ['free-callback.test', 'taken-callback.test'],
                                           metainfo: 'uid-321')

    result = Struct.new(:code, :body).new('200', { 'custom_field_1' => 'uid-321' }.to_json)

    EisBilling::SendCallbackService.stub :call, result do
      BusinessRegistry::DomainAvailabilityCheckerService.stub :filter_available, ['free-callback.test'] do
        get eis_billing_callback_path, params: { payment_reference: 'ref-3', order_reference: invoice.invoice_number }
      end
    end

    assert_response :unprocessable_entity
    assert_equal 'Failed to reserve domains', JSON.parse(response.body)['message']
    assert invoice.reload.pending?
    assert_nil ReservedDomain.find_by(name: 'free-callback.test')
  end
end
