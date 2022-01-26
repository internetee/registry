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
