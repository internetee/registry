class InvoiceMailer < ApplicationMailer
  def invoice_email(invoice:, recipient:)
    @invoice = invoice

    subject = default_i18n_subject(invoice_number: invoice.number)
    attachments["invoice-#{invoice.number}.pdf"] = invoice.as_pdf
    mail(to: recipient, subject: subject)
  end
end