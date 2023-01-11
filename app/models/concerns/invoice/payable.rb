module Invoice::Payable
  extend ActiveSupport::Concern

  included do
    scope :unpaid, -> { where('id NOT IN (SELECT invoice_id FROM account_activities WHERE' \
                          ' invoice_id IS NOT NULL)') }
  end

  def payable?
    unpaid? && not_cancelled?
  end

  def paid?
    account_activity.present?
  end

  def receipt_date
    return unless paid?

    account_activity.created_at.to_date
  end

  def unpaid?
    !paid?
  end

  def process_payment(**options)
    payment = options[:payment_type].constantize.new(invoice: self)
    payment.response = options[:everypay_response]
    payment.status = options[:payment_status]
    payment.save!

    bank_transaction = payment.base_transaction(sum: options[:sum],
                                                paid_at: options[:transaction_time] || Time.zone.now,
                                                buyer_name: buyer_name)
    bank_transaction.bind_invoice(number)
  end

  def autobind_manually
    return if paid?

    bank_statement = BankStatement.new(
      bank_code: Setting.registry_bank_code,
      iban: Setting.registry_iban
    )
    bank_statement.bank_transactions.build(
      description: description,
      sum: total,
      reference_no: reference_no,
      paid_at: Time.zone.now.to_date,
      currency: 'EUR'
    )
    bank_statement.save!
    bank_statement.bind_invoices(manual: true)
  end
end
