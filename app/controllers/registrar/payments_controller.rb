class Registrar
  class PaymentsController < BaseController
    protect_from_forgery except: [:callback]

    skip_authorization_check # actually anyone can pay, no problems at all
    skip_before_action :authenticate_registrar_user!, :check_ip_restriction,
                       only: [:callback]

    before_action :check_supported_payment_method, only: [:pay]

    def pay
      invoice = Invoice.find(params[:invoice_id])

      respond_to do |format|
        format.html { redirect_to invoice.linkpay_url_builder } if invoice
      end
    end

    def callback
      invoice = Invoice.find_by(number: linkpay_params[:order_reference])
      payment_order = find_payment_order(invoice: invoice, ref: linkpay_params[:order_reference])

      payment_order.response = {
        order_reference: linkpay_params[:order_reference],
        payment_reference: linkpay_params[:payment_reference],
      }
      payment_order.save

      payment_order.check_linkpay_status

      render status: :ok, json: { status: 'ok' }
    end

    private

    def linkpay_params
      params.permit(:order_reference, :payment_reference)
    end

    def find_payment_order(invoice:, ref:)
      order = invoice.payment_orders.every_pay.for_payment_reference(ref).first
      return order if order

      PaymentOrder.new_with_type(type: 'every_pay', invoice: invoice)
    end

    def check_supported_payment_method
      return if PaymentOrder.supported_method?(params[:bank], shortname: true)

      raise(StandardError, 'Not supported payment method')
    end
  end
end
