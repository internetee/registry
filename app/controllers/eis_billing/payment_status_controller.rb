module EisBilling
  class PaymentStatusController < ApplicationController
    skip_authorization_check # Temporary solution
    skip_before_action :verify_authenticity_token # Temporary solution

    TYPE = "PaymentOrders::EveryPay".freeze

    def update
      invoice_number = params[:order_reference]
      paid_at = params[:transaction_time]
      sum = params[:standing_amount]
      everypay_response = params
      payment_status = nil

      if PaymentOrders::EveryPay::SUCCESSFUL_PAYMENT.include? params[:payment_state]
        payment_status = :paid
      elsif params[:payment_state] == 'failed'
        payment_status = :failed
      end

      invoice = Invoice.find_by(number: invoice_number)

      bank = BankTransaction.new
      bank.description = invoice.order
      bank.reference_no = invoice.reference_no
      bank.currency = invoice.currency
      bank.iban = invoice.seller_iban
      bank.sum = sum
      bank.paid_at = paid_at
      bank.buyer_name = invoice.buyer_name
      bank.save

      p "++++ BANK TRANSACTION ERRORS ? ++++"
      p bank.errors

      payment = PaymentOrder.new
      payment.type = TYPE
      payment.invoice = invoice
      payment.response = everypay_response
      payment.status = payment_status
      payment.save

      p "++++ PAYMENT ORDER ERRORS ? ++++"
      p bank.errors

      registrar = Registrar.find_by(reference_no: params[:reference_number])
      bank.create_activity(registrar, invoice)

      render status: 200, json: { status: 'ok' }
    end
  end
end
