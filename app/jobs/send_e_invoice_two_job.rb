class SendEInvoiceTwoJob < ApplicationJob
  discard_on HTTPClient::TimeoutError

  def perform(invoice_id, payable: true)
    logger.info "Started to process e-invoice for invoice_id #{invoice_id}"
    invoice = Invoice.find_by(id: invoice_id)
    return unless need_to_process_invoice?(invoice: invoice, payable: payable)

    send_invoice_to_eis_billing(invoice: invoice, payable: payable)
    invoice.update(e_invoice_sent_at: Time.zone.now)
  rescue StandardError => e
    log_error(invoice: invoice, error: e)
    raise e
  end

  private

  def need_to_process_invoice?(invoice:, payable:)
    logger.info "Checking if need to process e-invoice #{invoice}, payable: #{payable}"
    return false if invoice.blank?
    return false if invoice.do_not_send_e_invoice? && payable

    true
  end

  def send_invoice_to_eis_billing(invoice:, payable:)
    result = EisBilling::SendEInvoice.send_request(invoice: invoice, payable: payable)
    logger.info result.body
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
