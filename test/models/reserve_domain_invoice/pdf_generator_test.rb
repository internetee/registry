require 'test_helper'

class ReserveDomainInvoice::PdfGeneratorTest < ActiveSupport::TestCase
  def setup
    @invoice = ReserveDomainInvoice.create!(
      invoice_number: '67890',
      domain_names: ['unregistered.test', 'sample.test'],
      metainfo: 'meta-uid',
      reference_no: '6789012',
      due_date: Date.new(2026, 11, 15)
    )
  end

  test 'renders eraisik when private individual and no customer name provided' do
    html = render_for(private_individual: true)

    assert_includes html, 'eraisik'
    refute_includes html, '[Kliendi nimi]'
    refute_includes html, '[Kliendi aadress]'
    refute_includes html, '[Kliendi VAT number]'
    refute_includes html, 'KMKR / VAT nr'
  end

  test 'renders full company details when name, address and VAT are provided' do
    html = render_for(
      customer_name: 'Example OÜ',
      customer_address: 'Tartu mnt 25, Tallinn',
      customer_vat_no: 'EE123456789'
    )

    assert_includes html, 'Example OÜ'
    assert_includes html, 'Tartu mnt 25, Tallinn'
    assert_includes html, 'KMKR / VAT nr'
    assert_includes html, 'EE123456789'
    refute_includes html, 'eraisik'
    refute_includes html, '[Kliendi nimi]'
    refute_includes html, '[Kliendi aadress]'
    refute_includes html, '[Kliendi VAT number]'
  end

  test 'renders unregistered company by name only without leaking placeholders' do
    html = render_for(customer_name: 'Future Company OÜ (asutamisel)')

    assert_includes html, 'Future Company OÜ (asutamisel)'
    refute_includes html, 'eraisik'
    refute_includes html, 'KMKR / VAT nr'
    refute_includes html, '[Kliendi nimi]'
    refute_includes html, '[Kliendi aadress]'
    refute_includes html, '[Kliendi VAT number]'
  end

  test 'renders name and address but hides VAT row when VAT number is blank' do
    html = render_for(
      customer_name: 'Partial Company OÜ',
      customer_address: 'Mustika 1, Tallinn'
    )

    assert_includes html, 'Partial Company OÜ'
    assert_includes html, 'Mustika 1, Tallinn'
    refute_includes html, 'KMKR / VAT nr'
    refute_includes html, '[Kliendi VAT number]'
  end

  test 'prefers customer_name over private_individual=true when both supplied' do
    html = render_for(
      private_individual: true,
      customer_name: 'Override Company OÜ'
    )

    assert_includes html, 'Override Company OÜ'
    refute_includes html, 'eraisik'
  end

  test 'renders unpaid invoice with bank transfer details and amount due' do
    html = render_for(paid: false, payment_date: Date.new(2026, 10, 20))

    assert_includes html, 'Arve number'
    assert_includes html, 'Viitenumber'
    assert_includes html, '6789012'
    assert_includes html, 'Maksetähtaeg'
    assert_includes html, I18n.l(@invoice.due_date)
    assert_includes html, 'Tasumata'
    assert_includes html, 'Tasuda'
    assert_includes html, 'Ootab tasumist'
    refute_includes html, 'Tasutud summa'
    refute_includes html, 'Reserveeritud'
    refute_includes html, 'Makse kuupäev'
  end

  test 'renders paid invoice with paid amount and payment date' do
    html = render_for(paid: true, payment_date: Date.new(2026, 10, 20))

    assert_includes html, 'Viitenumber'
    assert_includes html, 'Maksetähtaeg'
    assert_includes html, 'Tasutud summa'
    assert_includes html, 'Reserveeritud'
    assert_includes html, 'Makse kuupäev'
    assert_includes html, I18n.l(Date.new(2026, 10, 20))
    refute_includes html, 'Tasumata'
    refute_includes html, 'Tasuda'
  end

  test 'hides reference number and due date for older invoices' do
    @invoice.update!(reference_no: nil, due_date: nil)

    html = render_for(paid: true)

    refute_includes html, 'Viitenumber'
    refute_includes html, 'Maksetähtaeg'
    assert_includes html, 'Tasutud summa'
  end

  private

  def render_for(context = {})
    pdf = ReserveDomainInvoice::PdfGenerator.new(@invoice, context)
    ApplicationController.render(template: 'reserve_domain_invoices/pdf', assigns: { pdf: pdf })
  end
end
