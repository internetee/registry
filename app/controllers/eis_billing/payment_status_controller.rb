module EisBilling
  class PaymentStatusController < EisBilling::BaseController
    TYPE = 'PaymentOrders::EveryPay'.freeze

    def update
      invoice_number = params[:order_reference]
      paid_at = params[:transaction_time]
      sum = params[:standing_amount]
      everypay_response = params

      logger.info 'REQUEST FROM BILLING'
      logger.info params

      payment_status = define_payment_status(params[:payment_state])

      invoice = Invoice.find_by(number: invoice_number)

      bank = create_bank_transfer(invoice: invoice, sum: sum, paid_at: paid_at)
      create_payment_order(invoice: invoice, everypay_response: everypay_response, payment_status: payment_status)

      registrar = invoice.buyer
      bank.create_activity(registrar, invoice)

      render status: 200, json: { status: :ok }
    end

    private

    def define_payment_status(status)
      return :paid if PaymentOrders::EveryPay::SUCCESSFUL_PAYMENT.include? status

      :failed
    end

    def create_payment_order(invoice:, everypay_response:, payment_status:)
      payment = PaymentOrder.new
      payment.type = TYPE
      payment.invoice = invoice
      payment.response = everypay_response
      payment.status = payment_status
      payment.save

      logger.info '++++ PAYMENT ORDER ERRORS ? ++++'
      logger.info payment.errors

      payment
    end

    def create_bank_transfer(invoice:, sum:, paid_at:)
      bank = BankTransaction.new
      bank.description = invoice.order
      bank.reference_no = invoice.reference_no
      bank.currency = invoice.currency
      bank.iban = invoice.seller_iban
      bank.sum = sum
      bank.paid_at = paid_at
      bank.buyer_name = invoice.buyer_name
      bank.save

      logger.info '++++ BANK TRANSACTION ERRORS ? ++++'
      logger.info bank.errors

      bank
    end
  end
end
