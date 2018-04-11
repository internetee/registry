class Registrar
  module Payments
    class EveryPayController < BaseController
      load_resource class: Invoice
      skip_authorization_check only: [:new, :update]
      skip_before_action :verify_authenticity_token, only: :update

      def new
        set_invoice
        @every_pay = EveryPayPayment.new(@invoice)
      end

      def create
        set_invoice
      end

      def update
        set_invoice
        render 'complete'
      end

      private

      def set_invoice
        @invoice = Invoice.find(params[:invoice_id])
      end
    end
  end
end
