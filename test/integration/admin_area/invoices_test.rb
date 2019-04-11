require 'test_helper'

class AdminAreaInvoicesIntegrationTest < ApplicationIntegrationTest
  setup do
    @invoice = invoices(:one)
    sign_in users(:admin)
  end

  def test_downloads_invoice
    assert_equal 1, @invoice.number

    get download_admin_invoice_path(@invoice)

    assert_response :ok
    assert_equal 'application/pdf', response.headers['Content-Type']
    assert_equal 'attachment; filename="invoice-1.pdf"', response.headers['Content-Disposition']
    assert_not_empty response.body
  end
end