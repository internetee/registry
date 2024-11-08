module EisBilling
  class BusinessRegistryCallbackController < ApplicationController
    skip_authorization_check

    def callback

      result = EisBilling::SendCallbackService.call(reference_number: params[:payment_reference])

      invoice_number = params[:order_reference]

      puts '----'
      puts result.body
      puts result.code
      puts invoice_number
      puts '----'

      if result.code == '200'
        reserve_domain_invoice = ReserveDomainInvoice.find_by(number: invoice_number)
        filtered_domains = BusinessRegistry::DomainAvailabilityCheckerService.filter_available(reserve_domain_invoice.domain_names)

        reserved_domains = []

        # TODO:
        # - create reservied domains
        # - somehow bind them to the current invoice, maybe need to add some field there
        # - find invoices where are the same domains

        filtered_domains.each do |domain|
          reserved_domains << ReservedDomain.create(name: domain)
        end

        reserve_domain_invoice.paid!

        pending_invoices = ReserveDomainInvoice.pending.where('domain_names && ARRAY[?]::varchar[]', reserve_domain_invoice.domain_names)

        # - cancel them or recreate and change the price ?!?!


        render status: :ok, json: { message: 'Callback received' }
      else
        render status: :internal_server_error, json: { message: 'Callback failed' }
      end

    end
  end
end