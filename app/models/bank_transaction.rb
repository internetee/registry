class BankTransaction < ActiveRecord::Base
  include Versions
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
  def autobind_invoice
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
    create_activity(registrar, invoice)
  end
  # rubocop: enable Metrics/PerceivedComplexity
  # rubocop: enable Metrics/CyclomaticComplexity

  def bind_invoice(invoice_id)
    if binded?
      errors.add(:base, I18n.t('transaction_is_already_binded'))
      return
    end

    invoice = Invoice.find_by(id: invoice_id)

    unless invoice
      errors.add(:base, I18n.t('invoice_was_not_found'))
      return
    end

    if invoice.binded?
      errors.add(:base, I18n.t('invoice_is_already_binded'))
      return
    end

    if invoice.sum != sum
      errors.add(:base, I18n.t('invoice_and_transaction_sums_do_not_match'))
      return
    end

    create_activity(invoice.buyer, invoice)
  end

  def create_activity(registrar, invoice)
    create_account_activity(
      account: registrar.cash_account,
      invoice: invoice,
      sum: sum,
      currency: currency,
      description: description
    )
  end
end
