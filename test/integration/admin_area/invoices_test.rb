require 'test_helper'

class AdminAreaInvoicesIntegrationTest < ApplicationIntegrationTest
  setup do
    @invoice = invoices(:one)
    sign_in users(:admin)
  end

  def test_create_new_invoice
    visit new_admin_invoice_path

    assert_text 'Create new invoice'
    select 'Best Names', from: 'deposit_registrar_id', match: :first

    fill_in 'Amount', with: '1000'

    click_on 'Save'

    # TODO
    # Should be assert_text 'Record created'
    assert_equal page.status_code, 200
  end

  def test_visit_list_of_invoices_pages
    visit admin_invoices_path
    assert_text 'Invoices'
  end

  def test_visit_invoice_page
    visit admin_invoices_path(id: @invoice.id)
    assert_text "Invoice no. #{@invoice.number}"
  end

  def test_downloads_invoice
    assert_equal 1, @invoice.number

    get download_admin_invoice_path(@invoice)

    assert_response :ok
    assert_equal 'application/pdf', response.headers['Content-Type']
    assert_equal "attachment; filename=\"invoice-1.pdf\"; filename*=UTF-8''invoice-1.pdf", response.headers['Content-Disposition']
    assert_not_empty response.body
  end
end
