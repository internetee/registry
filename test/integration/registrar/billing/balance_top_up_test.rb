require 'test_helper'

class BalanceTopUpTest < ActionDispatch::IntegrationTest
  def setup
    login_as users(:api_bestnames)
  end

  def test_creates_new_invoice
    visit registrar_invoices_url
    click_link_or_button 'Add deposit'
    fill_in 'Amount', with: '25.5'

    Registry.instance.stub(:vat_rate, 10) do
      assert_difference 'Invoice.count' do
        click_link_or_button 'Add'
      end
    end

    invoice = Invoice.last

    assert_equal BigDecimal('28.05'), invoice.sum_cache
    assert_text 'Please pay the following invoice'
  end
end
