require 'application_system_test_case'

class NewInvoiceTest < ApplicationSystemTestCase
  def setup
    super

    @user = users(:api_bestnames)
    sign_in @user

    eis_response = OpenStruct.new(body: "{\"payment_link\":\"http://link.test\"}")
    Spy.on_instance_method(EisBilling::AddDeposits, :send_invoice).and_return(eis_response)
  end

  def test_show_balance
    visit registrar_invoices_path
    assert_text "Your current account balance is 100,00 EUR"
  end

  def test_create_new_invoice_with_positive_amount
    if Feature.billing_system_integrated?
      invoice_n = Invoice.order(number: :desc).last.number
      stub_request(:post, "http://eis_billing_system:3000/api/v1/invoice_generator/invoice_number_generator").
        to_return(status: 200, body: "{\"invoice_number\":\"#{invoice_n + 3}\"}", headers: {})

      stub_request(:put, "http://registry:3000/eis_billing/e_invoice_response").
        to_return(status: 200, body: "{\"invoice_number\":\"#{invoice_n + 3}\"}, {\"date\":\"#{Time.zone.now-10.minutes}\"}", headers: {})

      stub_request(:post, "http://eis_billing_system:3000/api/v1/e_invoice/e_invoice").
        to_return(status: 200, body: "", headers: {})

      visit registrar_invoices_path
      click_link_or_button 'Add deposit'
      fill_in 'Amount', with: '200.00'
      fill_in 'Description', with: 'My first invoice'

      assert_difference 'Invoice.count', 1 do
        click_link_or_button 'Add'
      end

      assert_text 'Please pay the following invoice'
      assert_text "Invoice no. #{invoice_n + 3}"
      assert_text 'Subtotal 200,00 €'
      assert_text 'Pay invoice'
    end
  end

  def test_create_new_invoice_with_comma_in_number
    if Feature.billing_system_integrated?
      invoice_n = Invoice.order(number: :desc).last.number
      stub_request(:post, "http://eis_billing_system:3000/api/v1/invoice_generator/invoice_number_generator").
        to_return(status: 200, body: "{\"invoice_number\":\"#{invoice_n + 3}\"}", headers: {})

      stub_request(:put, "http://registry:3000/eis_billing/e_invoice_response").
        to_return(status: 200, body: "{\"invoice_number\":\"#{invoice_n + 3}\"}, {\"date\":\"#{Time.zone.now-10.minutes}\"}", headers: {})

      stub_request(:post, "http://eis_billing_system:3000/api/v1/e_invoice/e_invoice").
        to_return(status: 200, body: "", headers: {})

      visit registrar_invoices_path
      click_link_or_button 'Add deposit'
      fill_in 'Amount', with: '200,00'
      fill_in 'Description', with: 'My first invoice'

      assert_difference 'Invoice.count', 1 do
        click_link_or_button 'Add'
      end

      assert_text 'Please pay the following invoice'
      assert_text "Invoice no. #{invoice_n + 3}"
      assert_text 'Subtotal 200,00 €'
      assert_text 'Pay invoice'
    end
  end

  def test_create_new_invoice_fails_when_amount_is_0
    visit registrar_invoices_path
    click_link_or_button 'Add deposit'
    fill_in 'Amount', with: '0.00'
    fill_in 'Description', with: 'My first invoice'

    assert_no_difference 'Invoice.count' do
      click_link_or_button 'Add'
    end

    assert_text 'Amount is too small. Minimum deposit is 0.01 EUR'
  end

  def test_create_new_invoice_fails_when_amount_is_negative
    visit registrar_invoices_path
    click_link_or_button 'Add deposit'
    fill_in 'Amount', with: '-120.00'
    fill_in 'Description', with: 'My first invoice'

    assert_no_difference 'Invoice.count' do
      click_link_or_button 'Add'
    end

    assert_text 'Amount is too small. Minimum deposit is 0.01 EUR'
  end
end
