require 'test_helper'

class DirectoReserveDomainInvoiceForwardJobTest < ActiveJob::TestCase
  DIRECTO_URL = 'https://eis_billing_system:3000/api/v1/directo/directo'.freeze

  setup do
    SettingEntry.create!(code: 'directo_reservation_product_name', value: 'BRONEERING', format: 'string',
                         group: 'billing')
    @paid = ReserveDomainInvoice.create!(invoice_number: '555001', domain_names: ['paid.test'], metainfo: 'uid-1',
                                         status: :paid, paid_at: Time.zone.parse('2026-11-10'))
    ReserveDomainInvoice.create!(invoice_number: '555002', domain_names: ['sent.test'], metainfo: 'uid-2',
                                 status: :paid, paid_at: Time.zone.parse('2026-11-10'), in_directo: true)
    ReserveDomainInvoice.create!(invoice_number: '555003', domain_names: ['pending.test'], metainfo: 'uid-3')
    stub_request(:post, DIRECTO_URL).to_return(status: 200, body: 'ok')
  end

  test 'sends only paid invoices that are not in Directo yet as business registry' do
    DirectoReserveDomainInvoiceForwardJob.perform_now

    assert_requested(:post, DIRECTO_URL) do |request|
      body = JSON.parse(request.body)
      body['initiator'] == 'business_registry' &&
        body['invoice_data'].map { |invoice| invoice['number'] } == [555_001] &&
        body['invoice_data'].first['invoice_lines'].first['product_id'] == 'BRONEERING'
    end
  end

  test 'sends nothing until the Directo product code is configured' do
    Setting.directo_reservation_product_name = ''

    DirectoReserveDomainInvoiceForwardJob.perform_now

    assert_not_requested(:post, DIRECTO_URL)
  end
end
