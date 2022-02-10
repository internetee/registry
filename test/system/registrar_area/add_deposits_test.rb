require 'application_system_test_case'

class AddDepositsTest < ApplicationSystemTestCase
  include ActionMailer::TestHelper

  setup do
    sign_in users(:api_bestnames)
    @invoice = invoices(:one)

    ActionMailer::Base.deliveries.clear
  end

  def test_should_send_request_for_creating_invoice_to_eis_system
    if Feature.billing_system_integrated?
      invoice_n = Invoice.order(number: :desc).last.number
      stub_request(:post, "http://eis_billing_system:3000/api/v1/invoice_generator/invoice_generator").
        to_return(status: 200, body: "{\"everypay_link\":\"http://link.test\"}", headers: {})

      stub_request(:post, "http://eis_billing_system:3000/api/v1/invoice_generator/invoice_number_generator").
        to_return(status: 200, body: "{\"invoice_number\":\"#{invoice_n + 3}\"}", headers: {})

      stub_request(:put, "http://registry:3000/eis_billing/e_invoice_response").
        to_return(status: 200, body: "{\"invoice_number\":\"#{invoice_n + 3}\"}, {\"date\":\"#{Time.zone.now-10.minutes}\"}", headers: {})

      stub_request(:post, "http://eis_billing_system:3000/api/v1/e_invoice/e_invoice").
        to_return(status: 200, body: "", headers: {})

      visit new_registrar_deposit_url
      fill_in 'Amount', with: '100.0'
      click_button text: 'Add'

      assert_text 'Everypay link'
    end
  end
end
