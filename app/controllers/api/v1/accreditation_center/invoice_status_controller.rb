require 'serializers/repp/invoice'

module Api
  module V1
    module AccreditationCenter
      class InvoiceStatusController < BaseController
        api :GET, 'api/v1/accreditation_center/invoice_status'
        desc 'get invoice status'
        def index
          @invoices = @current_user.registrar.invoices.reject { |invoice| invoice.cancelled_at.nil? }

          if @invoices
            render_success(data: { invoices: serialize_invoices(@invoices) })
          else
            render_error('No cancelled invoices', :not_found)
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
