module Api
  module V1
    module BusinessRegistry
      class LongReserveDomainsStatusController < BaseController
        include ReservedDomainInvoiceScoped

        def show
          result = @reserved_domain_invoice.invoice_state

          if result.paid?
            @reserved_domain_invoice.create_paid_reserved_domains
            render json: { status: 'paid', message: result.message, reserved_domains: @reserved_domain_invoice.build_reserved_domains_output }
          else
            render json: { status: result.status, message: result.message, names: @reserved_domain_invoice.domain_names }
          end
        end
      end
    end
  end
end
