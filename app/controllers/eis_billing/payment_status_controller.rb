module EisBilling
  class PaymentStatusController < EisBilling::BaseController
    TYPE = 'PaymentOrders::EveryPay'.freeze

    def update
      invoice = Invoice.find_by(number: params[:order_reference])

      if invoice.paid?
        render json: { message: 'Invoice already paid' }, status: :ok
      else
        invoice.process_payment(
          payment_type: TYPE,
          everypay_response: params,
          payment_status: define_payment_status(params[:payment_state]),
          sum: params[:standing_amount],
          transaction_time: params[:transaction_time]
        )

        render json: { message: 'Payment is proccessing' }, status: :ok
      end
    end

    private

    def define_payment_status(status)
      return :paid if PaymentOrders::EveryPay::SUCCESSFUL_PAYMENT.include? status

      :failed
    end
  end
end
