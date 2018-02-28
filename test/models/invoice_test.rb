require 'test_helper'

class InvoiceTest < ActiveSupport::TestCase
  def test_invalid_without_vat_rate
    invoice = Invoice.new(vat_rate: nil)
    invoice.validate
    assert invoice.errors.added?(:vat_rate, :blank)
  end
end
