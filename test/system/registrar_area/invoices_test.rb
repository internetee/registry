require 'application_system_test_case'

class RegistrarAreaInvoicesTest < ApplicationSystemTestCase
  include ActionMailer::TestHelper

  setup do
    sign_in users(:api_bestnames)
    @invoice = invoices(:one)

    ActionMailer::Base.deliveries.clear
    eis_response = OpenStruct.new(body: "{\"payment_link\":\"http://link.test\"}")
    Spy.on_instance_method(EisBilling::AddDeposits, :send_invoice).and_return(eis_response)
  end

  def test_cancels_an_invoice
    @invoice.account_activity = nil
    assert @invoice.cancellable?

    visit registrar_invoice_url(@invoice)
    click_on 'Cancel'
    @invoice.reload

    assert @invoice.cancelled?
    assert_text 'Invoice has been cancelled'
  end

  def test_invoice_delivery_form_is_pre_populated_with_billing_email_of_a_registrar
    assert_equal 'billing@bestnames.test', @invoice.buyer.billing_email
    visit new_registrar_invoice_delivery_url(@invoice)
    assert_field 'Recipient', with: 'billing@bestnames.test'
  end

  def test_delivers_an_invoice
    visit registrar_invoice_url(@invoice)
    click_on 'Send'
    fill_in 'Recipient', with: 'billing@registrar.test'
    click_on 'Send'

    assert_emails 1
    email = ActionMailer::Base.deliveries.first
    assert_equal ['billing@registrar.test'], email.to
    assert_current_path registrar_invoice_path(@invoice)
    assert_text 'Invoice has been sent'
  end

  def test_if_invoice_unpaid_should_be_present_everypay_link
    eis_response = OpenStruct.new(body: "{\"payment_link\":\"http://link.test\"}")
    Spy.on_instance_method(EisBilling::AddDeposits, :send_invoice).and_return(eis_response)
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
    invoice = invoices(:unpaid)
    visit registrar_invoice_url(invoice)

    assert_text 'Everypay link'
  end

  def test_if_invoice_unpaid_and_not_generated_link_comes_then_should_render_no_everypay_link
    invoice = invoices(:unpaid)
    visit registrar_invoice_url(invoice)

    assert_text 'No everypay link'
  end

  def test_if_invoice_aldready_paid_there_should_not_any_everypay_link
    visit registrar_invoice_url(@invoice)

    assert_no_text 'No everypay link'
    assert_no_text 'Everypay link'
  end
end
