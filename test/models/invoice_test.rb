require 'test_helper'

class InvoiceTest < ActiveSupport::TestCase
  setup do
    @invoice = invoices(:valid)
  end

  def test_valid
    assert @invoice.valid?
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
    invoice.invoice_items = @invoice.invoice_items
    invoice.vat_rate = BigDecimal('25.5')
    invoice.save!
    invoice.reload
    assert_equal BigDecimal('25.5'), invoice.vat_rate
  end

  def test_vat_rate_defaults_to_effective_vat_rate_of_a_registrar
    registrar = registrars(:bestnames)
    invoice = @invoice.dup
    invoice.vat_rate = nil
    invoice.buyer = registrar
    invoice.invoice_items = @invoice.invoice_items

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
    assert_equal BigDecimal('1.5'), @invoice.vat_amount
  end

  def test_vat_amount_is_zero_when_vat_rate_is_blank
    @invoice.vat_rate = nil
    assert_equal 0, @invoice.vat_amount
  end

  def test_calculates_subtotal
    line_item = InvoiceItem.new
    invoice = Invoice.new(invoice_items: [line_item, line_item])

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
    invoice.invoice_items = [line_item, line_item]

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
    invoice.invoice_items = @invoice.invoice_items
    invoice.save!
    assert_equal 'US1234', invoice.buyer_vat_no
  end
end
