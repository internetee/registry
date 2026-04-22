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

          send_data @reserved_domain_invoice.as_pdf,
                    filename: "invoice-#{@reserved_domain_invoice.invoice_number}.pdf",
                    type: 'application/pdf',
                    disposition: 'attachment'
        end
      end
    end
  end
end
