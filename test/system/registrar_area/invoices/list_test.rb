require 'test_helper'

class ListInvoicesTest < ApplicationSystemTestCase
  setup do
    @user = users(:api_bestnames)
    @invoice = invoices(:one)

    sign_in @user
  end

  def test_show_balance
    visit registrar_invoices_path
    assert_text "Your current account balance is 100,00 EUR"
  end

  def test_shows_invoice_owned_by_current_user
    owning_registrar = registrars(:bestnames)
    assert_equal owning_registrar, @user.registrar
    @invoice.update!(buyer: owning_registrar)

    visit registrar_invoices_url

    assert_text @invoice.to_s
  end

  def test_hides_invoice_owned_by_other_user
    other_registrar = registrars(:goodnames)
    assert_not_equal other_registrar, @user.registrar
    @invoice.update!(buyer: other_registrar)

    visit registrar_invoices_url

    assert_no_text @invoice.to_s
  end
end