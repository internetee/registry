module Payments
  PAYMENT_METHODS = ENV['payment_methods'].strip.split(', ').freeze
  PAYMENT_BANKLINK_BANKS = ENV['payment_banklink_banks'].strip.split(', ').freeze

  def self.create_with_type(type, invoice, opts = {})
    fail ArgumentError unless PAYMENT_METHODS.include?(type)

    if PAYMENT_BANKLINK_BANKS.include?(type)
      BankLink.new(type, invoice, opts)
    elsif type == 'every_pay'
      # TODO: refactor to be variable
      EveryPay.new(type, invoice, opts)
    end
  end
end
