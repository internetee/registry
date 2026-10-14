module EisBilling
  class BusinessRegistryCallbackController < ApplicationController
    skip_authorization_check
    around_action :set_audit_context

    def callback
      result = EisBilling::SendCallbackService.call(reference_number: params[:payment_reference])

      invoice_number = params[:order_reference]
      user_unique_id = JSON.parse(result.body)['custom_field_1']

      if result.code == '200'
        reserve_domain_invoice = ReserveDomainInvoice.find_by(invoice_number: invoice_number, metainfo: user_unique_id)
        filtered_domains = BusinessRegistry::DomainAvailabilityCheckerService.filter_available(reserve_domain_invoice.domain_names)

        unless filtered_domains.count == reserve_domain_invoice.domain_names.count
          return render status: :unprocessable_entity, json: { message: 'Failed to reserve domains' }
        end

        reserved_domains = []
        ReservedDomain::Audit.set(reason: 'paid_reservation', reason_note: nil, registrar_id: nil) do
          filtered_domains.each do |domain|
            reserved_domains << ReservedDomain.create(
              name: domain,
              expire_at: ReservedDomain.expire_at_for(ReservedDomain::PAID_RESERVATION_EXPIRY)
            )
          end
        end
        reserve_domain_invoice.paid!
        ReserveDomainInvoice.cancel_intersecting_invoices(reserve_domain_invoice)

        render status: :ok, json: { message: 'Callback received' }
      else
        render status: :internal_server_error, json: { message: 'Callback failed' }
      end

    end

    private

    def set_audit_context
      ::PaperTrail.request(whodunnit: 'EIS billing callback') do
        ReservedDomain::Audit.set(source: 'eis_billing', reason: nil,
                                  reason_note: nil, registrar_id: nil) { yield }
      end
    end
  end
end