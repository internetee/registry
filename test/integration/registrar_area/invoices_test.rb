require 'test_helper'

class RegistrarAreaInvoicesIntegrationTest < ApplicationIntegrationTest
  setup do
    @invoice = invoices(:one)
    sign_in users(:api_bestnames)
  end

  def test_download_invoice_pdf
    get download_pdf_registrar_invoice_path(@invoice)
    assert_response :ok
  end
end