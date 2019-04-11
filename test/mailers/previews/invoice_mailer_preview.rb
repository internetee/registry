class InvoiceMailerPreview < ActionMailer::Preview
  def invoice_email
    invoice = Invoice.first
    InvoiceMailer.invoice_email(invoice: invoice, recipient: 'billing@registrar.test')
  end
end