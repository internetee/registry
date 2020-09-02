require 'application_system_test_case'

class BalanceTopUpTest < ApplicationSystemTestCase
  setup do
    sign_in users(:api_bestnames)
    @original_registry_vat_rate = Setting.registry_vat_prc
  end

  teardown do
    Setting.registry_vat_prc = @original_registry_vat_rate
  end

  def test_creates_new_invoice
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
  end
end
