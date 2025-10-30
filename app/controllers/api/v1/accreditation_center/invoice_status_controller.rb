module Api
  module V1
    module AccreditationCenter
      class InvoiceStatusController < BaseController
        def index
          @invoices = @current_user.registrar.invoices.select { |i| i.cancelled_at != nil }

          if @invoices
            render json: { code: 1000, invoices: @invoices },
                   status: :ok
          else
            render json: { errors: 'No invoices' }, status: :not_found
          end
        end
      end
    end
  end
end
