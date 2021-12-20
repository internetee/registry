require 'application_system_test_case'

class NewInvoicePaymentTest < ApplicationSystemTestCase
  def setup
    super

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

  def test_create_new_Every_Pay_payment
    create_invoice_and_visit_its_page

    assert_link('Pay')
  end
end
