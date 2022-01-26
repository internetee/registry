require 'application_system_test_case'

class NewInvoicePaymentTest < ApplicationSystemTestCase
  def setup
    super
    eis_response = OpenStruct.new(body: "{\"payment_link\":\"http://link.test\"}")
    Spy.on_instance_method(EisBilling::AddDeposits, :send_invoice).and_return(eis_response)

    @original_vat_prc = Setting.registry_vat_prc
    Setting.registry_vat_prc = 0.2
    @user = users(:api_bestnames)
    sign_in @user
  end

  def teardown
    super

    Setting.registry_vat_prc = @original_vat_prc
  end

  def create_invoice_and_visit_its_page
    visit registrar_invoices_path
    click_link_or_button 'Add deposit'
    fill_in 'Amount', with: '200.00'
    fill_in 'Description', with: 'My first invoice'
    click_link_or_button 'Add'
  end

  def test_create_new_SEB_payment
    invoice_n = Invoice.order(number: :desc).last.number
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
    create_invoice_and_visit_its_page
    click_link_or_button 'seb'
    form = page.find('form')
    assert_equal('https://www.seb.ee/cgi-bin/dv.sh/ipank.r', form['action'])
    assert_equal('post', form['method'])
    assert_equal('240.00', form.find_by_id('VK_AMOUNT', visible: false).value)
  end

  def test_create_new_Every_Pay_payment
    invoice_n = Invoice.order(number: :desc).last.number
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
    create_invoice_and_visit_its_page
    click_link_or_button 'every_pay'
    expected_hmac_fields = 'account_id,amount,api_username,callback_url,' +
                           'customer_url,hmac_fields,nonce,order_reference,timestamp,transaction_type'

    form = page.find('form')
    assert_equal('https://igw-demo.every-pay.com/transactions/', form['action'])
    assert_equal('post', form['method'])
    assert_equal(expected_hmac_fields, form.find_by_id('hmac_fields', visible: false).value)
    assert_equal('240.00', form.find_by_id('amount', visible: false).value)
  end
end
