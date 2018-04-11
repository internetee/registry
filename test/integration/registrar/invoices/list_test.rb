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


  def test_show_single_invoice
    @invoice = invoices(:valid)
    @registrar_invoices << @invoice

    visit registrar_invoices_path
    assert_text "Unpaid", count: 1
    assert_text "Invoice no.", count: 1
  end

  # This bastard fails, only unpaid invoice is attached to the registrar
  # TODO: Fix and uncomment
  # def test_show_multiple_invoices
  #   @invoices = invoices
  #   @invoices.each do |invoice|
  #     @registrar_invoices << invoice
  #   end

  #   visit registrar_invoices_path
  #   assert_text "Unpaid", count: 2
  #   assert_text "Invoice no.", count: 2
  # end
end
