require 'application_system_test_case'

class AdminAreaInvoicesTest < ApplicationSystemTestCase
  include ActionMailer::TestHelper

  setup do
    sign_in users(:admin)
    @invoice = invoices(:one)

    ActionMailer::Base.deliveries.clear
  end

  def test_cancels_an_invoice
    @invoice.account_activity = nil
    assert @invoice.cancellable?

    visit admin_invoice_url(@invoice)
    click_on 'Cancel'
    @invoice.reload

    assert @invoice.cancelled?
    assert_text 'Invoice has been cancelled'
  end

  def test_invoice_delivery_form_is_pre_populated_with_billing_email_of_a_registrar
    assert_equal 'billing@bestnames.test', @invoice.buyer.billing_email
    visit new_admin_invoice_delivery_url(@invoice)
    assert_field 'Recipient', with: 'billing@bestnames.test'
  end

  def test_delivers_an_invoice
    visit admin_invoice_url(@invoice)
    click_on 'Send'
    fill_in 'Recipient', with: 'billing@registrar.test'
    click_on 'Send'

    assert_emails 1
    email = ActionMailer::Base.deliveries.first
    assert_equal ['billing@registrar.test'], email.to
    assert_current_path admin_invoice_path(@invoice)
    assert_text 'Invoice has been sent'
  end

  def test_download_invoices_list_as_csv
    travel_to Time.zone.parse('2010-07-05 10:30')

    visit admin_invoices_url
    click_link('CSV')

    assert_equal "attachment; filename=\"invoices_#{Time.zone.now.to_formatted_s(:number)}.csv\"; filename*=UTF-8''invoices_#{Time.zone.now.to_formatted_s(:number)}.csv", response_headers['Content-Disposition']
    assert_equal file_fixture('invoices.csv').read, page.body
  end
end
