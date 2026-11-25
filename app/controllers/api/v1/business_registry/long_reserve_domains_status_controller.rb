module Api
  module V1
    module BusinessRegistry
      class LongReserveDomainsStatusController < BaseController
        include ReservedDomainInvoiceScoped

        def show
          result = @reserved_domain_invoice.invoice_state

          if result.paid?
            # Billing does not call back for EveryPay payments, so polling is where the invoice becomes paid
            @reserved_domain_invoice.reserve_paid_domains if @reserved_domain_invoice.pending?
            render json: { status: 'paid', message: result.message, reserved_domains: @reserved_domain_invoice.build_reserved_domains_output }
          else
            render json: { status: result.status, message: result.message, names: @reserved_domain_invoice.domain_names }
          end
        end
      end
    end
  end
end
