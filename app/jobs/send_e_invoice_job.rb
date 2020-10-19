class SendEInvoiceJob < ApplicationJob
  queue_as :default
  discard_on HTTPClient::TimeoutError

  def perform(invoice_id, payable = true)
    invoice = Invoice.find_by(id: invoice_id)
    return unless need_to_process_invoice?(invoice: invoice, payable: payable)

    process(invoice: invoice, payable: payable)
  rescue StandardError => e
    log_error(invoice: invoice, error: e)
    raise e
  end

  private

  def need_to_process_invoice?(invoice:, payable:)
    return false if invoice.blank?
    return false if invoice.do_not_send_e_invoice? && payable

    true
  end

  def process(invoice:, payable:)
    invoice.to_e_invoice(payable: payable).deliver
    invoice.update(e_invoice_sent_at: Time.zone.now)
    log_success(invoice)
  end

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
