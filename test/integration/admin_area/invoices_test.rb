require 'test_helper'

class AdminAreaInvoicesIntegrationTest < ApplicationIntegrationTest
  setup do
    @invoice = invoices(:one)
    sign_in users(:admin)
    
    @account = accounts(:cash)
    @registrar = registrars(:bestnames)
  end
  
  def test_cancel_paid_invoice
    @invoice.account_activity.update(sum: 10)
    assert @invoice.paid?

    assert_equal @registrar.balance, 100

    assert_no_difference 'Invoice.count' do
      assert_difference 'AccountActivity.count' do
        post cancel_paid_admin_invoices_path(id: @invoice.id) + "?invoice_id=#{@invoice.id}"
      end
    end
    assert_equal @registrar.balance, 90
  end

  def test_create_new_invoice
    if Feature.billing_system_integrated?
      invoice_n = Invoice.order(number: :desc).last.number

      stub_request(:post, "http://eis_billing_system:3000/api/v1/invoice_generator/invoice_generator").
        to_return(status: 200, body: "{\"everypay_link\":\"http://link.test\"}", headers: {})

      stub_request(:post, "http://eis_billing_system:3000/api/v1/invoice_generator/invoice_number_generator").
        to_return(status: 200, body: "{\"invoice_number\":\"#{invoice_n + 3}\"}", headers: {})

      stub_request(:put, "http://registry:3000/eis_billing/e_invoice_response").
        to_return(status: 200, body: "{\"invoice_number\":\"#{invoice_n + 3}\"}, {\"date\":\"#{Time.zone.now-10.minutes}\"}", headers: {})

      stub_request(:post, "http://eis_billing_system:3000/api/v1/e_invoice/e_invoice").
        to_return(status: 200, body: "", headers: {})

      visit new_admin_invoice_path

      assert_text 'Create new invoice'
      select 'Best Names', from: 'deposit_registrar_id', match: :first
      fill_in 'Amount', with: '1000'
      click_on 'Save'

      assert_equal page.status_code, 200
    end
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
