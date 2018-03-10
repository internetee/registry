require 'test_helper'

class BalanceTopUpTest < ActionDispatch::IntegrationTest
  def setup
    login_as users(:api_bestnames)
  end

  def test_registrar_balance_top_up
    visit registrar_invoices_url
    click_link_or_button 'Add deposit'
    fill_in 'Amount', with: 100
    click_link_or_button 'Add'

    assert_text 'Please pay the following invoice'
  end
end
