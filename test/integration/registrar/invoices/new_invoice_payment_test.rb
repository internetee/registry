require 'test_helper'

class NewInvoicePaymentTest < ActionDispatch::IntegrationTest
  def setup
    super

    @user = users(:api_bestnames)
    login_as @user
  end

  def create_invoice_and_visit_its_page
    visit registrar_invoices_path
    click_link_or_button 'Add deposit'
    fill_in 'Amount', with: '200.00'
    fill_in 'Description', with: 'My first invoice'
    click_link_or_button 'Add'
  end

  def test_create_new_SEB_payment
    create_invoice_and_visit_its_page
    click_link_or_button 'Seb'
    form = page.find('form')
    assert_equal('https://www.seb.ee/cgi-bin/dv.sh/ipank.r', form['action'])
    assert_equal('post', form['method'])
    assert_equal('240.00', form.find_by_id('VK_AMOUNT', visible: false).value)
  end

  def test_create_new_Every_Pay_payment
    create_invoice_and_visit_its_page
    click_link_or_button 'Every pay'
    expected_hmac_fields = 'account_id,amount,api_username,callback_url,' +
                           'customer_url,hmac_fields,nonce,order_reference,timestamp,transaction_type'

    form = page.find('form')
    assert_equal('https://igw-demo.every-pay.com/transactions/', form['action'])
    assert_equal('post', form['method'])
    assert_equal(expected_hmac_fields, form.find_by_id('hmac_fields', visible: false).value)
    assert_equal('240.00', form.find_by_id('amount', visible: false).value)
  end
end
