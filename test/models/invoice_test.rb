require 'test_helper'

class InvoiceTest < ActiveSupport::TestCase
  def setup
    @invoice = invoices(:valid)
  end

  def test_valid
    assert @invoice.valid?
  end

  def test_invalid_without_vat_rate
    @invoice.vat_rate = nil
    assert @invoice.invalid?
  end

  def test_allows_absent_vat_rate
    @invoice.vat_rate = nil
    @invoice.validate
    assert @invoice.valid?
  end

  def test_rejects_negative_vat_rate
    @invoice.vat_rate = -1
    @invoice.validate
    assert @invoice.invalid?
  end

  def test_rejects_vat_rate_greater_than_max
    @invoice.vat_rate = 100
    @invoice.validate
    assert @invoice.invalid?
  end
end
