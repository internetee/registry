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
    @invoice.update!(account_activity: nil, cancelled_at: nil, issue_date: '2010-07-04',
                     due_date: '2010-07-04')

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

  def test_serializes_and_deserializes_vat_rate
    @invoice.vat_rate = BigDecimal('25.5')
    @invoice.save!
    @invoice.reload
    assert_equal BigDecimal('25.5'), @invoice.vat_rate
  end

  def test_calculates_vat_amount
    invoice_item = InvoiceItem.new(price: 25, quantity: 2)
    invoice = Invoice.new(vat_rate: 10, items: [invoice_item, invoice_item.dup])
    assert_equal 10, invoice.vat_amount
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
    invoice.buyer = registrar
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

  def test_returns_combined_seller_address
    invoice = Invoice.new(seller_street: 'street', seller_city: 'city', seller_state: 'state',
                          seller_zip: nil)
    assert_equal 'street, city, state', invoice.seller_address
  end

  def test_assumes_correct_sum_amount_when_created_by_transaction
    registrar = registrars(:bestnames)

    bank_transaction = bank_transactions(:one).dup
    bank_transaction.reference_no = registrar.reference_no
    bank_transaction.sum = 5
    bank_transaction.save

    invoice = Invoice.create_from_transaction!(bank_transaction)
    assert_equal 5, invoice.total
  end
end
