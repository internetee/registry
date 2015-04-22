class InvoiceMailer < ApplicationMailer
  def invoice_email(invoice, pdf)
    unless Rails.env.production?
      test_emails = ['martin@gitlab.eu', 'priit@gitlab.eu']
      return unless test_emails.include?(invoice.billing_email)
    end

    @invoice = invoice

    attachments[invoice.pdf_name] = pdf
    mail(to: invoice.billing_email, subject: invoice)
  end
end
