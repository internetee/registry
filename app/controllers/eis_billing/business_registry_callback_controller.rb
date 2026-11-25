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

        if reserve_domain_invoice.reserve_paid_domains == :reserved
          render status: :ok, json: { message: 'Callback received' }
        else
          render status: :unprocessable_entity, json: { message: 'Failed to reserve domains' }
        end
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