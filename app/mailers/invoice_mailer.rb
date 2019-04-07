class InvoiceMailer < ApplicationMailer
  include Que::Mailer

  def invoice_email(invoice_id, html, billing_email)
    @invoice = Invoice.find_by(id: invoice_id)
    billing_email ||= @invoice.billing_email
    return unless @invoice

    kit = PDFKit.new(html)
    pdf = kit.to_pdf
    invoice = @invoice

    attachments[invoice.pdf_name] = pdf
    mail(to: format(billing_email), subject: invoice)
  end
end
