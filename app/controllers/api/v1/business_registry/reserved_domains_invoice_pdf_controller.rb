module Api
  module V1
    module BusinessRegistry
      class ReservedDomainsInvoicePdfController < BaseController
        include ReservedDomainInvoiceScoped

        def show
          result = @reserved_domain_invoice.invoice_state

          unless result.paid?
            render_error('Invoice is not paid', :unprocessable_entity, { status: result.status, message: result.message })
            return
          end

          send_data @reserved_domain_invoice.as_pdf(invoice_context),
                    filename: "invoice-#{@reserved_domain_invoice.invoice_number}.pdf",
                    type: 'application/pdf',
                    disposition: 'attachment'
        end

        private

        def invoice_context
          {
            customer_name: params[:customer_name].presence,
            customer_address: params[:customer_address].presence,
            customer_vat_no: params[:customer_vat_no].presence,
            private_individual: ActiveModel::Type::Boolean.new.cast(params[:private_individual]),
            payment_date: parse_date(params[:payment_date])
          }
        end

        def parse_date(value)
          return nil if value.blank?

          Date.parse(value.to_s)
        rescue ArgumentError
          nil
        end
      end
    end
  end
end
