require 'application_system_test_case'

class AddDepositsTest < ApplicationSystemTestCase
  include ActionMailer::TestHelper

  setup do
    sign_in users(:api_bestnames)
    @invoice = invoices(:one)

    ActionMailer::Base.deliveries.clear
  end

  def test_should_send_request_for_creating_invoice_to_eis_system
    eis_response = OpenStruct.new(body: "{\"payment_link\":\"http://link.test\"}")
    Spy.on_instance_method(EisBilling::AddDeposits, :send_invoice).and_return(eis_response)

    visit new_registrar_deposit_url
    fill_in 'Amount', with: '100.0'
    click_button text: 'Add'

    assert_text 'Everypay link'
  end
end
