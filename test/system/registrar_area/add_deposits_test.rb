require 'application_system_test_case'

class AddDepositsTest < ApplicationSystemTestCase
  include ActionMailer::TestHelper

  setup do
    sign_in users(:api_bestnames)
    @invoice = invoices(:one)

    ActionMailer::Base.deliveries.clear
  end

  def test_should_send_request_for_creating_invoice_to_eis_system
    invoice_n = Invoice.order(number: :desc).last.number
    stub_request(:post, "http://eis_billing_system:3000/api/v1/invoice_generator/invoice_number_generator").
      with(
        headers: {
              'Accept'=>'Bearer WA9UvDmzR9UcE5rLqpWravPQtdS8eDMAIynzGdSOTw==--9ZShwwij3qmLeuMJ--NE96w2PnfpfyIuuNzDJTGw==',
              'Accept-Encoding'=>'gzip;q=1.0,deflate;q=0.6,identity;q=0.3',
              'Authorization'=>'Bearer foobar',
              'Content-Type'=>'application/json',
              'User-Agent'=>'Ruby'
            }).
      to_return(status: 200, body: "{\"invoice_number\":\"#{invoice_n + 3}\"}", headers: {})
    eis_response = OpenStruct.new(body: "{\"payment_link\":\"http://link.test\"}")
    Spy.on_instance_method(EisBilling::AddDeposits, :send_invoice).and_return(eis_response)

    visit new_registrar_deposit_url
    fill_in 'Amount', with: '100.0'
    click_button text: 'Add'

    assert_text 'Everypay link'
  end
end
