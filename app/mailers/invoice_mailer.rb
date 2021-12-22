class InvoiceMailer < ApplicationMailer
  def invoice_email(invoice:, recipient:, paid: false)
    @invoice = invoice

    @linkpay_url = invoice.linkpay_url unless paid
    subject = default_i18n_subject(invoice_number: invoice.number)
    subject << I18n.t('invoice.already_paid') if paid
    attachments["invoice-#{invoice.number}.pdf"] = invoice.as_pdf
    mail(to: recipient, subject: subject)
  end
end
