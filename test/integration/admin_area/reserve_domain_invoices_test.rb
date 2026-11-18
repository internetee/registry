require 'test_helper'

class AdminAreaReserveDomainInvoicesTest < ApplicationIntegrationTest
  setup do
    sign_in users(:admin)
    @invoice = ReserveDomainInvoice.create!(invoice_number: '556001', domain_names: ['admin-list.test'],
                                            metainfo: 'uid', buyer_name: 'Listed Buyer OÜ',
                                            status: :paid, paid_at: Time.zone.now)
  end

  test 'lists reservation invoices with buyer' do
    get admin_reserve_domain_invoices_path, params: { q: { invoice_number_eq: '556001' } }

    assert_response :success
    assert_includes response.body, 'Listed Buyer OÜ'
    assert_includes response.body, 'admin-list.test'
  end

  test 'downloads the invoice pdf as paid' do
    captured_context = nil
    generator = ->(_invoice, context) { captured_context = context; Struct.new(:as_pdf).new('%PDF-1.4 admin') }

    ReserveDomainInvoice::PdfGenerator.stub :new, generator do
      get download_admin_reserve_domain_invoice_path(@invoice)
    end

    assert_response :success
    assert_equal 'application/pdf', response.headers['Content-Type']
    assert_equal true, captured_context[:paid]
  end
end
