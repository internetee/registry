class InvoiceMailer < ApplicationMailer
  def invoice_email(invoice, pdf)
    attachments[invoice.pdf_name] = pdf
    mail(to: invoice.billing_email, subject: invoice)
  end
end
