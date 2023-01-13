module EisBilling
  class InvoicesController < BaseController
    TYPE = 'PaymentOrders::EveryPay'.freeze
    PAID = 'paid'.freeze
    CANCELLED = 'cancelled'.freeze
    ISSUED = 'unpaid'.freeze
    FAILED = 'failed'.freeze

    before_action :load_invoice, only: :update

    def update
      p '=========='
      p params
      p '=========='

      if @invoice.update(modified_params) && payment_orders_handler

        render json: {
          message: 'Invoice data was successfully updated',
        }, status: :ok
      else
        render json: {
          error: {
            message: @invoice.errors.full_messages
          }
        }, status: :unprocessable_entity
      end
    end

    private

    def payment_orders_handler
      p '-----'
      p @invoice.cancelled?
      p status.issued?
      p status
      p '------'

      if @invoice.payment_orders.present?
        if @invoice.cancelled? && status.paid? || @invoice.cancelled? && status.issued?
          @invoice.errors.add(:base, 'Unable to change status of record')

          return false
        end

        if @invoice.paid? && (status.failed? || status.cancelled?)
          @invoice.errors.add(:base, 'Unable to change status of record')

          return false
        end

        return true if (@invoice.paid? && status.paid?) || (@invoice.unpaid? && status.issued?) || (@invoice.cancelled? && status.cancelled?)

        if status.issued?
          @invoice.cancel_manualy
        elsif status.paid?
          @invoice.autobind_manually
        else
          @invoice.cancel
        end
      else
        return unless status.paid?

        @invoice.autobind_manually
      end
    end

    def status
      status = case params[:status][:status]
               when 'paid'
                 'paid'
               when 'cancelled'
                 'cancelled'
               when 'failed'
                 'failed'
               else
                 'unpaid'
               end

      Struct.new(:paid?, :cancelled?, :issued?, :failed?)
            .new(status == PAID, status == CANCELLED, status == ISSUED, status == FAILED)
    end

    def load_invoice
      @invoice = Invoice.find_by(number: params[:invoice][:invoice_number])
      return if @invoice.present?

      render json: {
        error: {
          message: "Invoice with #{params[:invoice][:invoice_number]} number not found",
        }
      }, status: :not_found and return
    end

    def modified_params
      {
        in_directo: params[:invoice][:in_directo],
        e_invoice_sent_at: params[:invoice][:sent_at_omniva],
      }
    end
  end
end
