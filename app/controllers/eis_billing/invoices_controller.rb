module EisBilling
  class InvoicesController < BaseController
    before_action :load_invoice, only: :update
    skip_before_action :verify_authenticity_token, only: [:update]

    def update
      state = InvoiceStateMachine.new(invoice: @invoice, status: params[:status])

      puts '-----'
      puts @invoice
      params[:status]
      puts '----'

      if @invoice.update(modified_params) && state.call
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
