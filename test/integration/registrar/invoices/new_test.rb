require 'test_helper'

class NewInvoiceTest < ActionDispatch::IntegrationTest
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

  # This test case should fail once issue #651 gets fixed
  def test_create_new_invoice_with_amount_0_goes_through
    visit registrar_invoices_path
    click_link_or_button 'Add deposit'
    fill_in 'Amount', with: '0.00'
    fill_in 'Description', with: 'My first invoice'

    assert_difference 'Invoice.count', 1 do
      click_link_or_button 'Add'
    end

    assert_text 'Please pay the following invoice'
    assert_text 'Invoice no. 131050'
    assert_text 'Subtotal 0,00 €'
    assert_text 'Pay invoice'
  end
end
