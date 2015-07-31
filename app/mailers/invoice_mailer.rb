class InvoiceMailer < ApplicationMailer
  def invoice_email(invoice, pdf)
    return if whitelist_blocked?(invoice.billing_email)

    @invoice = invoice
    attachments[invoice.pdf_name] = pdf
    mail(to: invoice.billing_email, subject: invoice)
  end
end
