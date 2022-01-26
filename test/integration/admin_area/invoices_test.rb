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
    invoice_n = Invoice.order(number: :desc).last.number

    stub_request(:post, "http://eis_billing_system:3000/api/v1/invoice_generator/invoice_generator").
  with(
    body: "{\"transaction_amount\":\"1200.0\",\"order_reference\":4,\"customer_name\":\"Best Names\",\"customer_email\":\"info@bestnames.test\",\"custom_field_1\":\"\",\"custom_field_2\":\"registry\",\"invoice_number\":4}",
    headers: {
	  'Accept'=>'Bearer WA9UvDmzR9UcE5rLqpWravPQtdS8eDMAIynzGdSOTw==--9ZShwwij3qmLeuMJ--NE96w2PnfpfyIuuNzDJTGw==',
	  'Accept-Encoding'=>'gzip;q=1.0,deflate;q=0.6,identity;q=0.3',
	  'Authorization'=>'Bearer foobar',
	  'Content-Type'=>'application/json',
	  'User-Agent'=>'Ruby'
    }).
  to_return(status: 200, body: "{\"everypay_link\":\"http://link.test\"}", headers: {})

    stub_request(:post, "http://eis_billing_system:3000/api/v1/invoice_generator/invoice_number_generator").
      with(
        headers: {
              'Accept'=>'Bearer WA9UvDmzR9UcE5rLqpWravPQtdS8eDMAIynzGdSOTw==--9ZShwwij3qmLeuMJ--NE96w2PnfpfyIuuNzDJTGw==',
              'Accept-Encoding'=>'gzip;q=1.0,deflate;q=0.6,identity;q=0.3',
              'Authorization'=>'Bearer foobar',
              'Content-Type'=>'application/json',
              'User-Agent'=>'Ruby'
            }).
      to_return(status: 200, body: "{\"invoice_number\":\"#{invoice_n + 3}\"}", headers: {})
    visit new_admin_invoice_path

    assert_text 'Create new invoice'
    select 'Best Names', from: 'deposit_registrar_id', match: :first
    fill_in 'Amount', with: '1000'
    click_on 'Save'

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
