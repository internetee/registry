require 'test_helper'

class NewInvoicePaymentTest < ActionDispatch::IntegrationTest
  setup do
    @original_methods             = ENV['payment_methods']
    @original_seb_URL             = ENV['seb_payment_url']
    @original_bank_certificate    = ENV['seb_bank_certificate']
    @original_seller_certificate  = ENV['seller_certificate']
    @original_ep_url              = ENV['every_pay_payment_url']
    ENV['payment_methods']        = 'seb, swed, every_pay'
    ENV['seb_payment_url']        = 'https://example.com/seb_url'
    ENV['seb_seller_account']     = 'SEB'
    ENV['seb_bank_certificate']   = 'test/fixtures/files/seb_bank_cert.pem'
    ENV['seb_seller_certificate'] = 'test/fixtures/files/seb_seller_key.pem'
    ENV['every_pay_payment_url']  = 'https://example.com/every_pay_url'
    @user = users(:api_bestnames)
    @original_vat_rate = @user.registrar.vat_rate
    @user.registrar.vat_rate = 0.2

    login_as @user
  end

  teardown do
    ENV['every_pay_payment_url']  = @original_ep_url
    ENV['payment_methods']        = @original_methods
    ENV['seb_payment_url']        = @original_seb_URL
    ENV['seb_bank_certificate']   = @original_bank_certificate
    ENV['seb_seller_certificate'] = @original_seller_certificate
    @user.registrar.vat_rate = @original_vat_rate
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
    assert_equal 'https://example.com/seb_url', form['action']
    assert_equal 'post', form['method']
    assert_equal '220.00', form.find_by_id('VK_AMOUNT', visible: false).value
  end

  def test_create_new_Every_Pay_payment
    create_invoice_and_visit_its_page
    save_and_open_page
    click_link_or_button 'Every pay'
    expected_hmac_fields = 'account_id,amount,api_username,callback_url,' +
      'customer_url,hmac_fields,nonce,order_reference,timestamp,transaction_type'

    form = page.find('form')
    assert_equal 'https://example.com/every_pay_url', form['action']
    assert_equal 'post', form['method']
    assert_equal expected_hmac_fields, form.find_by_id('hmac_fields', visible: false).value
    assert_equal '220.0', form.find_by_id('amount', visible: false).value
  end
end
