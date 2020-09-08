class BankStatement < ApplicationRecord
  include Versions
  has_many :bank_transactions

  accepts_nested_attributes_for :bank_transactions

  validates :bank_code, :iban, presence: true

  FULLY_BINDED = 'fully_binded'.freeze
  PARTIALLY_BINDED = 'partially_binded'.freeze
  NOT_BINDED = 'not_binded'.freeze

  # TODO: Cache this to database so it can be used for searching
  def status
    if bank_transactions.unbinded.count == bank_transactions.count
      NOT_BINDED
    elsif bank_transactions.unbinded.count.zero?
      FULLY_BINDED
    else
      PARTIALLY_BINDED
    end
  end

  def not_binded?
    status == NOT_BINDED
  end

  def partially_binded?
    status == PARTIALLY_BINDED
  end

  def fully_binded?
    status == FULLY_BINDED
  end

  def bind_invoices(manual: false)
    bank_transactions.unbinded.each do |transaction|
      transaction.autobind_invoice(manual: manual)
    end
  end
end
