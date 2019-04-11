require 'test_helper'

class RegistrarAreaInvoicesIntegrationTest < ApplicationIntegrationTest
  setup do
    @invoice = invoices(:one)
    sign_in users(:api_bestnames)
  end

  def test_downloads_invoice
    assert_equal 1, @invoice.number

    get download_registrar_invoice_path(@invoice)

    assert_response :ok
    assert_equal 'application/pdf', response.headers['Content-Type']
    assert_equal 'attachment; filename="invoice-1.pdf"', response.headers['Content-Disposition']
    assert_not_empty response.body
  end
end