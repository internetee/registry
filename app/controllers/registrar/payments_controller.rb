class Registrar
  class PaymentsController < BaseController
    protect_from_forgery except: %i[back callback]

    skip_authorization_check # actually anyone can pay, no problems at all
    skip_before_action :authenticate_registrar_user!, :check_ip_restriction,
                       only: %i[back callback]
    before_action :check_supported_payment_method

    def pay
      invoice = Invoice.find(params[:invoice_id])
      bank = params[:bank]
      opts = {
        return_url: registrar_return_payment_with_url(
          bank, invoice_id: invoice
        ),
        response_url: registrar_response_payment_with_url(
          bank, invoice_id: invoice
        ),
      }
      @payment = ::PaymentOrders.create_with_type(bank, invoice, opts)
      @payment.create_transaction
    end

    def back
      invoice = Invoice.find(params[:invoice_id])
      opts = { response: params }
      @payment = ::PaymentOrders.create_with_type(params[:bank], invoice, opts)
      if @payment.valid_response_from_intermediary? && @payment.settled_payment?
        @payment.complete_transaction

        if invoice.paid?
          flash[:notice] = t(:pending_applied)
        else
          flash[:alert] = t(:something_wrong)
        end
      else
        flash[:alert] = t(:something_wrong)
      end
      redirect_to registrar_invoice_path(invoice)
    end

    def callback
      invoice = Invoice.find(params[:invoice_id])
      opts = { response: params }
      @payment = ::PaymentOrders.create_with_type(params[:bank], invoice, opts)

      if @payment.valid_response_from_intermediary? && @payment.settled_payment?
        @payment.complete_transaction
      end

      render status: :ok, json: { status: 'ok' }
    end

    private

    def check_supported_payment_method
      return if supported_payment_method?

      raise StandardError, 'Not supported payment method'
    end

    def supported_payment_method?
      PaymentOrders::PAYMENT_METHODS.include?(params[:bank])
    end
  end
end
