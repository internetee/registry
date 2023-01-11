module EisBilling
  class InvoicesController < BaseController
    TYPE = 'PaymentOrders::EveryPay'.freeze

    before_action :load_invoice, only: :update

    def update
      if @invoice.update(modified_params)
        payment_orders_handler

        render json: {
          message: 'Invoice data was successfully updated'
        }, status: :ok
      else
        render json: {
          error: @message.errors.full_messages
        }, status: :unprocessable_entity
      end
    end

    private

    def payment_orders_handler
      if @invoice.payment_orders.present?
        return if (@invoice.paid? && status == 'paid') || (@invoice.cancelled? && status == 'cancelled')

        if status == 'cancelled' || status == 'failed'
          @invoice.cancel_manualy
        elsif status == 'paid'
          @invoice.autobind_manually
        end
      else
        return unless status == 'paid'

        @invoice.autobind_manually
      end
    end

    def status
      case params[:invoice][:status]
      when 'paid'
        'paid'
      when 'cancelled'
        'cancelled'
      when 'failed'
        'failed'
      else
        'issued'
      end
    end

    def load_invoice
      @invoice = Invoice.find_by(number: params[:invoice][:invoice_number])

      if @invoice.nil?
        render json: {
          error: {
            message: "Invoice with #{params[:invoice][:invoice_number]} number not found"
          }
        }, status: :not_found and return
      end
    end

    def modified_params
      {
        in_directo: params[:invoice][:in_directo],
        e_invoice_sent_at: params[:invoice][:sent_at_omniva]
      }
    end
  end
end
