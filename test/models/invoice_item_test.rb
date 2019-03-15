require 'test_helper'

class InvoiceItemTest < ActiveSupport::TestCase
  def test_calculates_sum_without_vat
    invoice_item = InvoiceItem.new(price: 5, quantity: 2)
    assert_equal 10, invoice_item.item_sum_without_vat
  end
end
