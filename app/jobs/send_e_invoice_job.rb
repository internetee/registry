class SendEInvoiceJob < Que::Job
  def run(invoice)
    destroy if invoice.do_not_send_e_invoice?

    invoice.to_e_invoice.deliver

    ActiveRecord::Base.transaction do
      invoice.update(e_invoice_sent_at: Time.zone.now)
      log_success(invoice)
      destroy
    end
  rescue Exception => e
    log_error(invoice: invoice, error: e)
    raise e
  end

  private

  def log_success(invoice)
    id = invoice.try(:id) || invoice
    message = "E-Invoice for an invoice with ID # #{id} was sent successfully"
    logger.info message
  end

  def log_error(invoice:, error:)
    id = invoice.try(:id) || invoice
    message = <<~TEXT.squish
      There was an error sending e-invoice for invoice with ID # #{id}.
      The error message was the following: #{error}.
      This job will retry
    TEXT
    logger.error message
  end

  def logger
    Rails.logger
  end
end
