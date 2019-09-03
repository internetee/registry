require 'application_system_test_case'

class NewInvoiceTest < ApplicationSystemTestCase
  def setup
    super

    @user = users(:api_bestnames)
    sign_in @user
  end

  def test_show_balance
    visit registrar_invoices_path
    assert_text "Your current account balance is 100,00 EUR"
  end

  def test_create_new_invoice_with_positive_amount
    visit registrar_invoices_path
    click_link_or_button 'Add deposit'
    fill_in 'Amount', with: '200.00'
    fill_in 'Description', with: 'My first invoice'

    assert_difference 'Invoice.count', 1 do
      click_link_or_button 'Add'
    end

    assert_text 'Please pay the following invoice'
    assert_text 'Invoice no. 131050'
    assert_text 'Subtotal 200,00 €'
    assert_text 'Pay invoice'
  end

  def test_create_new_invoice_with_comma_in_number
    visit registrar_invoices_path
    click_link_or_button 'Add deposit'
    fill_in 'Amount', with: '200,00'
    fill_in 'Description', with: 'My first invoice'

    assert_difference 'Invoice.count', 1 do
      click_link_or_button 'Add'
    end

    assert_text 'Please pay the following invoice'
    assert_text 'Invoice no. 131050'
    assert_text 'Subtotal 200,00 €'
    assert_text 'Pay invoice'
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
