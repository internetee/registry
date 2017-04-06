class Registrar
  class PaymentsController < BaseController
    protect_from_forgery except: :back

    skip_authorization_check # actually anyone can pay, no problems at all
    skip_before_action :authenticate_user!, :check_ip, only: [:back]
    before_action :check_bank

    # to handle existing model we should
    # get invoice_id and then get number
    # build BankTransaction without connection with right reference number
    # do not connect transaction and invoice
    def pay
      invoice = Invoice.find(params[:invoice_id])
      @bank_link = BankLink::Request.new(params[:bank], invoice, self)
      @bank_link.make_transaction
    end


    # connect invoice and transaction
    # both back and IPN
    def back
      @bank_link = BankLink::Response.new(params[:bank], params)
      if @bank_link.valid? && @bank_link.ok?
        @bank_link.complete_payment

        if @bank_link.invoice.binded?
          flash[:notice] = t(:pending_applied)
        else
          flash[:alert] = t(:something_wrong)
        end
      else
        flash[:alert] = t(:something_wrong)
      end
      redirect_to registrar_invoice_path(@bank_link.invoice)
    end

    private

    def banks
      ENV['payments_banks'].split(",").map(&:strip)
    end

    def check_bank
      raise StandardError.new("Not Implemented bank") unless banks.include?(params[:bank])
    end
  end
end
