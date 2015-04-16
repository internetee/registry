class BankTransaction < ActiveRecord::Base
  belongs_to :bank_statement
  has_one :account_activity

  scope :unbinded, -> { where('id NOT IN (SELECT bank_transaction_id FROM account_activities)') }

  def binded?
    account_activity.present?
  end

  def binded_invoice
    return unless binded?
    account_activity.invoice
  end

  # For successful binding, reference number, invoice id and sum must match with the invoice
  # rubocop: disable Metrics/PerceivedComplexity
  # rubocop: disable Metrics/CyclomaticComplexity
  def bind_invoice
    return if binded?
    registrar = Registrar.find_by(reference_no: reference_no)
    return unless registrar

    match = description.match(/^[^\d]*(\d+)/)
    return unless match

    invoice_id = match[1].to_i
    return unless invoice_id

    invoice = registrar.invoices.find_by(id: invoice_id)
    return unless invoice

    return if invoice.binded?

    return if invoice.sum != sum
    create_account_activity(
      account: registrar.cash_account,
      invoice: invoice,
      sum: sum,
      currency: currency,
      description: description
    )
  end
  # rubocop: enable Metrics/PerceivedComplexity
  # rubocop: enable Metrics/CyclomaticComplexity
end
