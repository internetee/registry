require 'test_helper'

class RegistrarInvoiceEmailCancellationTest < ActiveJob::TestCase
  setup do
    @registrar = registrars(:bestnames)
    @registrar.update!(address_country_code: 'EE', reference_no: '1232', vat_rate: 24)
    @invoice_params = 100

    stub_request(:post, "https://eis_billing_system:3000/api/v1/invoice_generator/invoice_number_generator").
      to_return(status: 200, body: "{\"invoice_number\":\"123456\"}", headers: {})

    stub_request(:post, "https://eis_billing_system:3000/api/v1/invoice_generator/invoice_generator").
      to_return(status: 200, body: "{\"everypay_link\":\"http://link.test\"}", headers: {})

    stub_request(:put, "https://registry:3000/eis_billing/e_invoice_response").
      to_return(status: 200, body: "{\"invoice_number\":\"123456\"}, {\"date\":\"#{Time.zone.now}\"}", headers: {})

    stub_request(:post, "https://eis_billing_system:3000/api/v1/e_invoice/e_invoice").
      to_return(status: 200, body: "", headers: {})
  end

  def test_sends_email_when_registrar_does_not_accept_e_invoices_and_pdf_opt_in_is_true
    # Name does not contain 'einvoice', so stub returns 'MR' (not OK)
    @registrar.update!(name: 'simple-registrar', accept_pdf_invoices: true)

    assert_enqueued_jobs 1, only: ActionMailer::MailDeliveryJob do
      @registrar.issue_prepayment_invoice(@invoice_params)
    end
  end

  def test_sends_email_when_registrar_does_not_accept_e_invoices_and_pdf_opt_in_is_false
    # Name does not contain 'einvoice', so stub returns 'MR' (not OK)
    @registrar.update!(name: 'simple-registrar', accept_pdf_invoices: false)

    assert_enqueued_jobs 1, only: ActionMailer::MailDeliveryJob do
      @registrar.issue_prepayment_invoice(@invoice_params)
    end
  end

  def test_skips_email_when_registrar_accepts_e_invoices_and_pdf_opt_in_is_false
    @registrar.update!(name: 'einvoice-registrar', accept_pdf_invoices: false)

    assert_enqueued_jobs 0, only: ActionMailer::MailDeliveryJob do
      @registrar.issue_prepayment_invoice(@invoice_params)
    end
  end

  def test_sends_email_when_registrar_accepts_e_invoices_BUT_pdf_opt_in_is_true
    @registrar.update!(name: 'einvoice-registrar', accept_pdf_invoices: true)

    assert_enqueued_jobs 1, only: ActionMailer::MailDeliveryJob do
      @registrar.issue_prepayment_invoice(@invoice_params)
    end
  end
end
