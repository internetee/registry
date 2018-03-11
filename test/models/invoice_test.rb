require 'test_helper'

class InvoiceTest < ActiveSupport::TestCase
  def setup
    @invoice = invoices(:valid)
  end

  def test_valid
    assert @invoice.valid?
  end
end
