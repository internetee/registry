require 'test_helper'

class InvoiceDetailsTest < ActionDispatch::IntegrationTest
  def setup
    login_as users(:api)
  end

  def test_with_vat
    invoice = invoices(:with_vat)
    visit registrar_invoice_path(invoice)
    assert_selector '.total', text: 'VAT'
  end

  def test_without_vat
    invoice = invoices(:without_vat)
    visit registrar_invoice_path(invoice)
    assert_no_selector '.total', text: 'VAT'
  end
end
