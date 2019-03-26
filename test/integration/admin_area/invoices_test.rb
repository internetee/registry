require 'test_helper'

class AdminAreaInvoicesIntegrationTest < ApplicationIntegrationTest
  setup do
    @invoice = invoices(:one)
    sign_in users(:admin)
  end

  def test_download_invoice_pdf
    get admin_invoice_download_pdf_path(@invoice)
    assert_response :ok
  end
end