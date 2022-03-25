module EisBilling
  class SetInvoiceStatus
    TYPE = 'PaymentOrders::EveryPay'.freeze

    def self.ping_status(invoice)
      response = invoice.get_response_from_billing
      change_status_to_pay(response: response, invoice: invoice) if response[:status] == 'paid'
    end

    def self.change_status_to_pay(response:, invoice:)
      return if response[:everypay_response].nil?

      everypay_response = response[:everypay_response]
      bank = create_bank_transfer(invoice: invoice, sum: everypay_response['standing_amount'],
                                  paid_at: response[:transaction_time])
      create_payment_order(invoice: invoice, everypay_response: everypay_response, payment_status: response[:status])

      registrar = invoice.buyer
      bank.create_activity(registrar, invoice)
    end

    def self.create_payment_order(invoice:, everypay_response:, payment_status:)
      payment = PaymentOrder.new
      payment.type = TYPE
      payment.invoice = invoice
      payment.response = everypay_response
      payment.status = payment_status
      payment.save

      Rails.logger.info '++++ PAYMENT ORDER ERRORS ? ++++'
      Rails.logger.info payment.errors

      payment
    end

    def self.create_bank_transfer(invoice:, sum:, paid_at:)
      bank = BankTransaction.new
      bank.description = invoice.order
      bank.reference_no = invoice.reference_no
      bank.currency = invoice.currency
      bank.iban = invoice.seller_iban
      bank.sum = sum
      bank.paid_at = paid_at
      bank.buyer_name = invoice.buyer_name
      bank.save

      Rails.logger.info '++++ BANK TRANSACTION ERRORS ? ++++'
      Rails.logger.info bank.errors

      bank
    end
  end
end
