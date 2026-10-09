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
end
