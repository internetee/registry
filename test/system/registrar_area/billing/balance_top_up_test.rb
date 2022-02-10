require 'application_system_test_case'

class BalanceTopUpTest < ApplicationSystemTestCase
  setup do
    sign_in users(:api_bestnames)
    @original_registry_vat_rate = Setting.registry_vat_prc

    eis_response = OpenStruct.new(body: "{\"payment_link\":\"http://link.test\"}")
    Spy.on_instance_method(EisBilling::AddDeposits, :send_invoice).and_return(eis_response)
    Spy.on_instance_method(EisBilling::BaseController, :authorized).and_return(true)
  end

  teardown do
    Setting.registry_vat_prc = @original_registry_vat_rate
  end

  def test_creates_new_invoice
    if Feature.billing_system_integrated?
      invoice_n = Invoice.order(number: :desc).last.number
      stub_request(:post, "http://eis_billing_system:3000/api/v1/invoice_generator/invoice_number_generator").
        to_return(status: 200, body: "{\"invoice_number\":\"#{invoice_n + 3}\"}", headers: {})

      stub_request(:put, "http://registry:3000/eis_billing/e_invoice_response")
        .to_return(status: 200, body: "{\"invoice_number\":\"#{invoice_n + 3}\"}, {\"date\":\"#{Time.zone.now-10.minutes}\"}", headers: {})

      stub_request(:post, "http://eis_billing_system:3000/api/v1/e_invoice/e_invoice")
        .to_return(status: 200, body: "", headers: {})

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
end
