require 'test_helper'

class InvoiceTest < ActiveSupport::TestCase
  setup do
    @invoice = invoices(:one)
  end

  def test_fixture_is_valid
    assert @invoice.valid?, proc { @invoice.errors.full_messages }
  end

  def test_overdue_scope_returns_unpaid_uncancelled_invoices_with_past_due_date
    travel_to Time.zone.parse('2010-07-05')
    @invoice.update!(account_activity: nil, cancelled_at: nil, due_date: '2010-07-04')

    assert Invoice.overdue.include?(@invoice), 'Should return overdue invoice'
  end

  def test_overdue_scope_does_not_return_paid_invoices
    assert @invoice.paid?
    assert_not Invoice.overdue.include?(@invoice), 'Should not return paid invoice'
  end

  def test_overdue_scope_does_not_return_cancelled_invoices
    @invoice.update!(cancelled_at: '2010-07-05')
    assert_not Invoice.overdue.include?(@invoice), 'Should not return cancelled invoice'
  end

  def test_overdue_scope_does_not_return_invoices_with_due_due_of_today_or_in_the_future
    travel_to Time.zone.parse('2010-07-05')
    @invoice.update!(due_date: '2010-07-05')

    assert_not Invoice.overdue.include?(@invoice), 'Should not return non-overdue invoice'
  end

  def test_optional_vat_rate
    @invoice.vat_rate = nil
    assert @invoice.valid?
  end

  def test_vat_rate_validation
    @invoice.vat_rate = -1
    assert @invoice.invalid?

    @invoice.vat_rate = 0
    assert @invoice.valid?

    @invoice.vat_rate = 99.9
    assert @invoice.valid?

    @invoice.vat_rate = 100
    assert @invoice.invalid?
  end

  def test_serializes_and_deserializes_vat_rate
    invoice = @invoice.dup
    invoice.items = @invoice.items
    invoice.vat_rate = BigDecimal('25.5')
    invoice.save!
    invoice.reload
    assert_equal BigDecimal('25.5'), invoice.vat_rate
  end

  def test_vat_rate_defaults_to_effective_vat_rate_of_a_registrar
    registrar = registrars(:bestnames)
    invoice = @invoice.dup
    invoice.vat_rate = nil
    invoice.registrar = registrar
    invoice.items = @invoice.items

    registrar.stub(:effective_vat_rate, BigDecimal(55)) do
      invoice.save!
    end

    assert_equal BigDecimal(55), invoice.vat_rate
  end

  def test_vat_rate_cannot_be_updated
    @invoice.vat_rate = BigDecimal(21)
    @invoice.save!
    @invoice.reload
    refute_equal BigDecimal(21), @invoice.vat_rate
  end

  def test_calculates_vat_amount
    invoice_item = InvoiceItem.new(price: 25, quantity: 2)
    invoice = Invoice.new(vat_rate: 10, items: [invoice_item, invoice_item.dup])
    assert_equal 10, invoice.vat_amount
  end

  def test_vat_amount_is_zero_when_vat_rate_is_blank
    @invoice.vat_rate = nil
    assert_equal 0, @invoice.vat_amount
  end

  def test_calculates_subtotal
    line_item = InvoiceItem.new
    invoice = Invoice.new(items: [line_item, line_item])

    line_item.stub(:item_sum_without_vat, BigDecimal('2.5')) do
      assert_equal BigDecimal(5), invoice.subtotal
    end
  end

  def test_returns_persisted_total
    assert_equal BigDecimal('16.50'), @invoice.total
  end

  def test_calculates_total
    line_item = InvoiceItem.new
    invoice = Invoice.new
    invoice.vat_rate = 10
    invoice.items = [line_item, line_item]

    line_item.stub(:item_sum_without_vat, BigDecimal('2.5')) do
      assert_equal BigDecimal('5.50'), invoice.total
    end
  end

  def test_valid_without_buyer_vat_no
    @invoice.buyer_vat_no = ''
    assert @invoice.valid?
  end

  def test_buyer_vat_no_is_taken_from_registrar_by_default
    registrar = registrars(:bestnames)
    registrar.vat_no = 'US1234'
    invoice = @invoice.dup
    invoice.buyer_vat_no = nil
    invoice.registrar = registrar
    invoice.items = @invoice.items
    invoice.save!
    assert_equal 'US1234', invoice.buyer_vat_no
  end

  def test_invalid_without_invoice_items
    @invoice.items.clear
    assert @invoice.invalid?
  end

  def test_iterates_over_invoice_items
    invoice = Invoice.new(items: [InvoiceItem.new(description: 'test')])

    iteration_count = 0
    invoice.each do |invoice_item|
      assert_equal 'test', invoice_item.description
      iteration_count += 1
    end

    assert_equal 1, iteration_count
  end

  def test_returns_seller
    invoice = Invoice.new(seller_name: 'seller name',
                          seller_reg_no: 'seller reg number',
                          seller_vat_no: 'seller vat number',
                          seller_address: 'seller address',
                          seller_email: 'seller email',
                          seller_phone: 'seller phone',
                          seller_url: 'seller website',
                          seller_contact_name: 'seller contact person',
                          seller_iban: 'seller iban',
                          seller_swift: 'seller swift',
                          seller_bank: 'seller bank')

    assert_equal 'seller name', invoice.seller.name
    assert_equal 'seller reg number', invoice.seller.registration_number
    assert_equal 'seller vat number', invoice.seller.vat_number
    assert_equal 'seller address', invoice.seller.address
    assert_equal 'seller email', invoice.seller.email
    assert_equal 'seller phone', invoice.seller.phone
    assert_equal 'seller website', invoice.seller.website
    assert_equal 'seller contact person', invoice.seller.contact_person

    assert_equal 'seller iban', invoice.seller.bank_account.iban
    assert_equal 'seller swift', invoice.seller.bank_account.swift
    assert_equal 'seller bank', invoice.seller.bank_account.bank_name
  end

  def test_returns_buyer
    invoice = Invoice.new(buyer_name: 'buyer name',
                          buyer_reg_no: 'buyer reg number',
                          buyer_vat_no: 'buyer vat number',
                          buyer_address: 'buyer address',
                          buyer_email: 'buyer email',
                          buyer_phone: 'buyer phone',
                          buyer_url: 'buyer website')

    assert_equal 'buyer name', invoice.buyer.name
    assert_equal 'buyer reg number', invoice.buyer.registration_number
    assert_equal 'buyer vat number', invoice.buyer.vat_number
    assert_equal 'buyer address', invoice.buyer.address
    assert_equal 'buyer email', invoice.buyer.email
    assert_equal 'buyer phone', invoice.buyer.phone
    assert_equal 'buyer website', invoice.buyer.website
  end
end