require 'application_system_test_case'

class BalanceTopUpTest < ApplicationSystemTestCase
  setup do
    sign_in users(:api_bestnames)
  end

  def test_creates_new_invoice
    original_vat_prc = Setting.registry_vat_prc
    Setting.registry_vat_prc = 0.1

    visit registrar_invoices_url
    click_link_or_button 'Add deposit'
    fill_in 'Amount', with: '25.5'

    assert_difference 'Invoice.count' do
      click_link_or_button 'Add'
    end

    invoice = Invoice.last

    assert_equal BigDecimal(10), invoice.vat_rate
    assert_equal BigDecimal('28.05'), invoice.total
    assert_text 'Please pay the following invoice'

    Setting.registry_vat_prc = original_vat_prc
  end
end
