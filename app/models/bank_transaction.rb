class BankTransaction < ActiveRecord::Base
  include Versions
  belongs_to :bank_statement
  has_one :account_activity
  has_many :directo_records, as: :item, class_name: 'Directo'# Deprecated

  scope :unbinded, lambda {
    where('id NOT IN (SELECT bank_transaction_id FROM account_activities where bank_transaction_id IS NOT NULL)')
  }

  def binded?
    account_activity.present?
  end

  def binded_invoice
    return unless binded?
    account_activity.invoice
  end


  def invoice_num
    return @invoice_no if defined?(@invoice_no)

    match = description.match(/^[^\d]*(\d+)/)
    return unless match

    @invoice_no = match[1].try(:to_i)
  end

  def invoice
    @invoice ||= registrar.invoices.find_by(number: invoice_num) if registrar
  end

  def registrar
    @registrar ||= Registrar.find_by(reference_no: reference_no)
  end


  # For successful binding, reference number, invoice id and sum must match with the invoice
  # rubocop: disable Metrics/PerceivedComplexity
  # rubocop: disable Metrics/CyclomaticComplexity
  def autobind_invoice
    return if binded?
    return unless registrar
    return unless invoice_num
    return unless invoice

    return if invoice.binded?
    return if invoice.cancelled?

    return if invoice.sum != sum
    create_activity(registrar, invoice)
  end
  # rubocop: enable Metrics/PerceivedComplexity
  # rubocop: enable Metrics/CyclomaticComplexity

  def bind_invoice(invoice_no)
    if binded?
      errors.add(:base, I18n.t('transaction_is_already_binded'))
      return
    end

    invoice = Invoice.find_by(number: invoice_no)

    unless invoice
      errors.add(:base, I18n.t('invoice_was_not_found'))
      return
    end

    if invoice.binded?
      errors.add(:base, I18n.t('invoice_is_already_binded'))
      return
    end

    if invoice.cancelled?
      errors.add(:base, I18n.t('cannot_bind_cancelled_invoice'))
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
      sum: invoice.sum_without_vat,
      currency: currency,
      description: description,
      activity_type: AccountActivity::ADD_CREDIT
    )
  end
end
