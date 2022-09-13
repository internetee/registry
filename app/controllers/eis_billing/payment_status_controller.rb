module EisBilling
  class PaymentStatusController < EisBilling::BaseController
    TYPE = 'PaymentOrders::EveryPay'.freeze

    def update
      payment_status = define_payment_status(params[:payment_state])
      invoice = Invoice.find_by(number: params[:order_reference])

      return if invoice.paid?

      bank = create_bank_transfer(invoice: invoice, sum: params[:standing_amount], paid_at: params[:transaction_time])
      create_payment_order(invoice: invoice, everypay_response: params, payment_status: payment_status)

      registrar = invoice.buyer
      bank.create_activity(registrar, invoice)

      respond_to do |format|
        format.json do
          render status: :ok, content_type: 'application/json', layout: false, json: { message: 'ok' }
        end
      end
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

      bank
    end
  end
end
