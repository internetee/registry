class SendEInvoiceJob < ApplicationJob
  queue_as :default
  discard_on HTTPClient::TimeoutError

  def perform(invoice_id, payable = true)
    invoice = Invoice.find_by(id: invoice_id)
    return unless invoice
    return if invoice.do_not_send_e_invoice? && payable

    invoice.to_e_invoice(payable: payable).deliver
    ActiveRecord::Base.transaction do
      invoice.update(e_invoice_sent_at: Time.zone.now)
      log_success(invoice)
    end
  rescue StandardError => e
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
      The error message was the following: #{error}
      This job will retry.
    TEXT
    logger.error message
  end

  def logger
    Rails.logger
  end
end
