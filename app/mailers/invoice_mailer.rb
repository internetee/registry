class InvoiceMailer < ApplicationMailer
  include Que::Mailer

  def invoice_email(invoice_id, html)
    @invoice = Invoice.find_by(id: invoice_id)
    return unless @invoice
    return if whitelist_blocked?(@invoice.billing_email)

    kit = PDFKit.new(html)
    pdf = kit.to_pdf
    invoice = @invoice

    attachments[invoice.pdf_name] = pdf
    mail(to: format(invoice.billing_email), subject: invoice)
  end
end
