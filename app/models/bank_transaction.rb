class BankTransaction < ApplicationRecord
  include Versions
  belongs_to :bank_statement
  has_one :account_activity

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

  def invoice
    @invoice ||= registrar.invoices.order(created_at: :asc).unpaid.find_by(total: sum) if registrar
  end

  def registrar
    @registrar ||= Invoice.find_by(reference_no: parsed_ref_number)&.buyer
  end


  # For successful binding, reference number, invoice id and sum must match with the invoice
  def autobind_invoice
    return if binded?
    return unless registrar
    return unless invoice
    return unless invoice.payable?

    create_activity(registrar, invoice)
  end

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

    if invoice.paid?
      errors.add(:base, I18n.t('invoice_is_already_binded'))
      return
    end

    if invoice.cancelled?
      errors.add(:base, I18n.t('cannot_bind_cancelled_invoice'))
      return
    end

    if invoice.total != sum
      errors.add(:base, I18n.t('invoice_and_transaction_sums_do_not_match'))
      return
    end

    create_activity(invoice.buyer, invoice)
  end

  def create_activity(registrar, invoice)
    ActiveRecord::Base.transaction do
      create_account_activity!(account: registrar.cash_account,
                               invoice: invoice,
                               sum: invoice.subtotal,
                               currency: currency,
                               description: description,
                               activity_type: AccountActivity::ADD_CREDIT)
      reset_pending_registrar_balance_reload
    end
  end

  private

  def reset_pending_registrar_balance_reload
    return unless registrar.settings['balance_auto_reload']

    registrar.settings['balance_auto_reload'].delete('pending')
    registrar.save!
  end

  def parsed_ref_number
    reference_no || ref_number_from_description
  end

  def ref_number_from_description
    /(\d{7})/.match(description)[0]
  end
end
