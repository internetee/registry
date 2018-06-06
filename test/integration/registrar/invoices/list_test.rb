require 'test_helper'

class ListInvoicesTest < ActionDispatch::IntegrationTest
  def setup
    super

    @user = users(:api_bestnames)
    @registrar_invoices = @user.registrar.invoices
    login_as @user
  end

  def test_show_balance
    visit registrar_invoices_path
    assert_text "Your current account balance is 100,00 EUR"
  end

  def test_show_multiple_invoices
    @invoices = invoices
    @registrar_invoices = []
    @invoices.each do |invoice|
      @registrar_invoices << invoice
    end

    visit registrar_invoices_path
    assert_text "Unpaid", count: 5
    assert_text "Invoice no.", count: 7
  end
end
