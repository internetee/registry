class DirectoInvoiceForwardJob < ApplicationJob
  def perform(dry: false)
    data = collect_receipts_data

    EisBilling::SendDataToDirecto.send_request(object_data: data, monthly: false, dry: dry)
  end

  def collect_receipts_data
    unsent_invoices = Invoice.where(in_directo: false).non_cancelled
    collected_data = []

    unsent_invoices.each do |invoice|
      unless valid_invoice_conditions?(invoice)
        Rails.logger.info "[DIRECTO] Invoice #{invoice.number} has been skipped"
        next
      end

      collected_data << invoice.as_directo_json
    end

    collected_data
  end

  def valid_invoice_conditions?(invoice)
    if invoice.account_activity.nil? || invoice.account_activity.bank_transaction.nil? ||
       invoice.account_activity.bank_transaction.sum.nil? ||
       invoice.account_activity.bank_transaction.sum != invoice.total
      return false

    end

    true
  end
end
