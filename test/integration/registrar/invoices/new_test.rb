require 'test_helper'

class NewInvoiceTest < ActionDispatch::IntegrationTest
  setup do
    @user = users(:api_bestnames)
    login_as @user
    @original_vat_rate = @user.registrar.vat_rate
    @user.registrar.vat_rate = 0.2
  end

  teardown do
    @user.registrar.vat_rate = @original_vat_rate
    AccountActivity.destroy_all
    Invoice.destroy_all
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

  def test_create_new_invoices_and_display_a_list_of_them
    visit registrar_invoices_path
    click_link_or_button 'Add deposit'
    fill_in 'Amount', with: '200.00'
    fill_in 'Description', with: 'My first invoice'
    click_link_or_button 'Add'

    visit registrar_invoices_path
    click_link_or_button 'Add deposit'
    fill_in 'Amount', with: '300.00'
    fill_in 'Description', with: 'My second invoice'
    click_link_or_button 'Add'

    visit registrar_invoices_path
    assert_text "Unpaid", count: 2
    assert_text "Invoice no. 131050"
    assert_text "Invoice no. 131051"
    assert_text "240,00"
    assert_text "360,00"
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
