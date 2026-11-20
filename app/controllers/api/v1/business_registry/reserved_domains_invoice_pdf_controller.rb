module Api
  module V1
    module BusinessRegistry
      class ReservedDomainsInvoicePdfController < BaseController
        include ReservedDomainInvoiceScoped

        def show
          paid = @reserved_domain_invoice.invoice_state.paid?

          unless paid || @reserved_domain_invoice.pending?
            render_error('Invoice is cancelled', :unprocessable_entity, { status: @reserved_domain_invoice.status })
            return
          end

          store_buyer
          send_data @reserved_domain_invoice.as_pdf(invoice_context.merge(paid: paid)),
                    filename: "invoice-#{@reserved_domain_invoice.invoice_number}.pdf",
                    type: 'application/pdf',
                    disposition: 'attachment'
        end

        private

        # Older reservations were created without buyer details, keep the ones the PDF request brings
        def store_buyer
          return if @reserved_domain_invoice.buyer_name.present? || invoice_context[:customer_name].blank?

          @reserved_domain_invoice.update!(buyer_name: invoice_context[:customer_name],
                                           buyer_address: invoice_context[:customer_address],
                                           buyer_vat_no: invoice_context[:customer_vat_no])
        end

        def invoice_context
          @invoice_context ||= {
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
