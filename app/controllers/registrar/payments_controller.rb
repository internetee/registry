class Registrar
  class PaymentsController < BaseController
    protect_from_forgery except: [:back, :callback]

    skip_authorization_check # actually anyone can pay, no problems at all
    skip_before_action :authenticate_registrar_user!, :check_ip_restriction,
                       only: [:back, :callback]

    before_action :check_supported_payment_method, only: [:pay]

    def pay
      invoice = Invoice.find(params[:invoice_id])
      channel = params[:bank]

      @payment_order = PaymentOrder.new_with_type(type: channel, invoice: invoice)
      @payment_order.save
      @payment_order.reload

      respond_to do |format|
        format.html { redirect_to invoice.linkpay_url_builder } if @payment_order
      end
    end

    def back
      @payment_order = PaymentOrder.find_by!(id: params[:payment_order])
      @payment_order.update!(response: params.to_unsafe_h)

      if @payment_order.payment_received?
        @payment_order.complete_transaction
      end

      render status: 200, json: { status: 'ok' }
    end

    def callback
      @invoice = Invoice.find_by(number: params[:order_reference])
      order = @invoice.payment_orders.where(type: 'PaymentOrders::EveryPay').last
      @payment_order = order || PaymentOrder.new_with_type(type: 'every_pay', invoice: @invoice)
      @payment_order.update!(response: params.to_unsafe_h)
      @payment_order.reload

      CheckLinkpayStatusJob.set(wait: 1.minute).perform_later(@payment_order.id)
      render status: 200, json: { status: 'ok' }
    end

    private

    def check_supported_payment_method
      return if PaymentOrder.supported_method?(params[:bank], shortname: true)

      raise(StandardError, 'Not supported payment method')
    end
  end
end
