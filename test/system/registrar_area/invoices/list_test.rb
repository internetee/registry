require 'test_helper'

class ListInvoicesTest < ApplicationSystemTestCase
  setup do
    @user = users(:api_bestnames)
    sign_in @user

    @invoice = invoices(:one)
    eliminate_effect_of_other_invoices
  end

  def test_show_balance
    visit registrar_invoices_path
    assert_text "Your current account balance is 100,00 EUR"
  end

  def test_show_invoices_of_current_registrar
    registrar = registrars(:bestnames)
    @user.update!(registrar: registrar)

    visit registrar_invoices_url

    assert_css '.invoice'
  end

  def test_do_not_show_invoices_of_other_registrars
    registrar = registrars(:goodnames)
    @user.update!(registrar: registrar)

    visit registrar_invoices_url

    assert_no_css '.invoice'
  end

  private

  def eliminate_effect_of_other_invoices
    Invoice.connection.disable_referential_integrity do
      Invoice.delete_all("id != #{@invoice.id}")
    end
  end
end