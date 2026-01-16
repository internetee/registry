require 'serializers/repp/invoice'

module Api
  module V1
    module AccreditationCenter
      class InvoiceStatusController < BaseController
        def index
          @invoices = @current_user.registrar.invoices.reject { |invoice| invoice.cancelled_at.nil? }

          if @invoices
            render json: { invoices: serialize_invoices(@invoices) },
                   status: :ok
          else
            render json: { errors: 'No cancelled invoices' }, status: :not_found
          end
        end

        private

        def serialize_invoices(invoices)
          invoices.map { |i| Serializers::Repp::Invoice.new(i).to_json }
        end
      end
    end
  end
end
