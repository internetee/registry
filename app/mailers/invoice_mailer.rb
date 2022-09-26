class InvoiceMailer < ApplicationMailer
  def invoice_email(invoice:, recipient:, paid: false)
    @invoice = invoice

    subject = default_i18n_subject(invoice_number: invoice.number)
    subject << I18n.t('invoice.already_paid') if paid
    subject << I18n.t('invoice.monthly_invoice') if invoice.monthly_invoice
    attachments["invoice-#{invoice.number}.pdf"] = invoice.as_pdf
    mail(to: recipient, subject: subject)
  end
end
