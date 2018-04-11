class Registrar
  class PaymentsController < BaseController
    protect_from_forgery except: :back

    skip_authorization_check # actually anyone can pay, no problems at all
    skip_before_action :authenticate_user!, :check_ip_restriction, only: [:back]
    # before_action :check_bank

    # to handle existing model we should
    # get invoice_id and then get number
    # build BankTransaction without connection with right reference number
    # do not connect transaction and invoice
    # TODO: Refactor to :new
    def pay
      invoice = Invoice.find(params[:invoice_id])
      opts = {
        return_url: self.registrar_return_payment_with_url(params[:bank], invoice_id: invoice.id),
        response_url: self.registrar_return_payment_with_url(params[:bank])
      }
      @payment = ::Payments.create_with_type(params[:bank], invoice, opts)
      @payment.create_transaction
    end


    # connect invoice and transaction
    # both back and IPN
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

    private

    # def banks
    #   ENV['payments_banks'].split(",").map(&:strip)
    # end

    def check_bank
      raise StandardError.new("Not Implemented bank") unless banks.include?(params[:bank])
    end
  end
end
