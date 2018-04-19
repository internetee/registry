class Registrar
  class PaymentsController < BaseController
    protect_from_forgery except: [:back, :callback]

    skip_authorization_check # actually anyone can pay, no problems at all
    skip_before_action :authenticate_user!, :check_ip_restriction, only: [:back, :callback]
    # before_action :check_bank

    # TODO: Refactor to :new
    def pay
      invoice = Invoice.find(params[:invoice_id])
      opts = {
        return_url: self.registrar_return_payment_with_url(params[:bank], invoice_id: invoice.id),
        # TODO: Add required URL
        response_url: "https://53e21cc8.ngrok.io/registrar/pay/callback/every_pay"
      }
      @payment = ::Payments.create_with_type(params[:bank], invoice, opts)
      @payment.create_transaction
    end


    # TODO: Refactor to be restful
    def back
      invoice = Invoice.find(params[:invoice_id])
      opts = { response: params }
      @payment = ::Payments.create_with_type(params[:bank], invoice, opts)
      if @payment.valid_response? && @payment.settled_payment?
        @payment.complete_transaction

        if invoice.binded?
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
      @payment = ::Payments.create_with_type(params[:bank], invoice, opts)

      if @payment.valid_response? && @payment.settled_payment?
        @payment.complete_transaction

        if invoice.binded?
          render status: 200, json: { ok: :ok }
        end
      end
    end

    private

    def check_supported_payment_method
      unless supported_payment_method?
        raise StandardError.new("Not supported payment method")
      end
    end


    def supported_payment_method?
      raise StandardError.new("Not Implemented bank") unless banks.include?(params[:bank])
    end
  end
end
