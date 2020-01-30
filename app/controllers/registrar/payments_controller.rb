class Registrar
  class PaymentsController < BaseController
    protect_from_forgery except: [:back, :callback]

    skip_authorization_check # actually anyone can pay, no problems at all
    skip_before_action :authenticate_registrar_user!, :check_ip_restriction,
                       only: [:back, :callback]
    before_action :check_supported_payment_method

    def pay
      invoice = Invoice.find(params[:invoice_id])
      payment_type = params[:bank]

      channel = if payment_type == 'every_pay'
                  'PaymentOrders::EveryPay'
                elsif payment_type == 'seb'
                  'PaymentOrders::SEB'
                elsif payment_type == 'swed'
                  'PaymentOrders::Swed'
                elsif payment_type == 'lhv'
                  'PaymentOrders::LHV'
                end

      @payment_order = PaymentOrder.new(type: channel, invoice: invoice)
      @payment_order.save && @payment_order.reload

      @payment_order.return_url = registrar_return_payment_with_url(@payment_order)
      @payment_order.response_url = registrar_response_payment_with_url(@payment_order)

      @payment_order.save && @payment_order.reload
    end

    def back
      puts params

      @payment_order = PaymentOrder.find_by!(id: params[:bank])
      @payment_order.update!(response: params.to_unsafe_h)

      if @payment_order.valid_response_from_intermediary? && @payment_order.settled_payment?
        @payment_order.complete_transaction

        if @payment_order.invoice.paid?
          flash[:notice] = t(:pending_applied)
        else
          flash[:alert] = t(:something_wrong)
        end
      else
        flash[:alert] = t(:something_wrong)
      end
      redirect_to registrar_invoice_path(@payment_order.invoice)
    end

    def callback
      @payment_order = PaymentOrder.find_by!(id: params[:bank])
      @payment_order.update!(response: params.to_unsafe_h)

      if @payment_order.valid_response_from_intermediary? && @payment_order.settled_payment?
        @payment_order.complete_transaction
      end

      render status: 200, json: { status: 'ok' }
    end

    private

    def check_supported_payment_method
      return if supported_payment_method?

      raise StandardError.new('Not supported payment method')
    end

    def supported_payment_method?
      puts "Payment method param is #{params[:bank]}"
      # PaymentOrder::PAYMENT_METHODS.include?(params[:bank])
      true
    end
  end
end
