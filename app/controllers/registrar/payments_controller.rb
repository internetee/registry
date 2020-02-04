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

      @payment_order = PaymentOrder.create_with_type(type: channel, invoice: invoice)
      @payment_order.save && @payment_order.reload

      @payment_order.return_url = registrar_return_payment_with_url(@payment_order)
      @payment_order.response_url = registrar_response_payment_with_url(@payment_order)

      @payment_order.save && @payment_order.reload
    end

    def back
      @payment_order = PaymentOrder.find_by!(id: params[:payment_order])
      @payment_order.update!(response: params.to_unsafe_h)

      if @payment_order.payment_received?
        @payment_order.complete_transaction

        if @payment_order.invoice.paid?
          flash[:notice] = t(:pending_applied)
        else
          # flash[:alert] = t(:something_wrong)
          flash[:alert] = 'We fucked up'
        end
      else
        @payment_order.create_failure_report
        flash[:alert] = t(:something_wrong)
      end
      redirect_to registrar_invoice_path(@payment_order.invoice)
    end

    def callback
      @payment_order = PaymentOrder.find_by!(id: params[:payment_order])
      @payment_order.update!(response: params.to_unsafe_h)

      if @payment_order.payment_received?
        @payment_order.complete_transaction
      else
        @payment_order.create_failure_report
      end

      render status: 200, json: { status: 'ok' }
    end

    private

    def check_supported_payment_method
      return if PaymentOrder.supported_method?(params[:bank], shortname: true)

      raise(StandardError, 'Not supported payment method')
    end
  end
end
