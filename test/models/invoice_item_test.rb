require 'test_helper'

class InvoiceItemTest < ActiveSupport::TestCase
  def test_calculates_subtotal
    invoice_item = InvoiceItem.new(price: 5, quantity: 2)
    assert_equal 10, invoice_item.item_sum_without_vat
    assert_equal 10, invoice_item.subtotal
  end

  def test_returns_vat_rate
    vat_rate = 20
    invoice = Invoice.new(vat_rate: vat_rate)

    invoice_item = InvoiceItem.new(invoice: invoice)

    assert_equal vat_rate, invoice_item.vat_rate
  end

  def test_calculates_vat_amount
    invoice = Invoice.new(vat_rate: 20)
    invoice_item = InvoiceItem.new(price: 5, quantity: 2, invoice: invoice)
    assert_equal 2, invoice_item.vat_amount
  end

  def test_calculates_total
    invoice = Invoice.new(vat_rate: 20)
    invoice_item = InvoiceItem.new(price: 5, quantity: 2, invoice: invoice)
    assert_equal 12, invoice_item.total
  end

  def test_stores_history
    invoice = invoices(:one)
    invoice_item = invoice_items(:one)
    invoice_item.description = 'test'

    assert_difference 'invoice_item.versions.count', 1 do
      invoice_item.save!
    end
  end
end
