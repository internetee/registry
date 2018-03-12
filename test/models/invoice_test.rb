require 'test_helper'

class InvoiceTest < ActiveSupport::TestCase
  def setup
    @invoice = invoices(:valid)
  end

  def test_valid
    assert @invoice.valid?
  end

  def test_calculates_subtotal
    assert_equal BigDecimal('15'), @invoice.sum_without_vat
  end

  def test_calculates_vat_amount
    assert_equal BigDecimal('1.5'), @invoice.vat
  end

  def test_calculates_total
    assert_equal BigDecimal('16.5'), @invoice.sum
  end
end
