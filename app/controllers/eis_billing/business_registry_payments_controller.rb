module EisBilling
  class BusinessRegistryPaymentsController < EisBilling::BaseController
    around_action :set_audit_context

    def update
      reserve_domain_invoice = find_reserve_domain_invoice
      return render status: :not_found, json: { message: 'Invoice not found' } if reserve_domain_invoice.nil?

      if reserve_domain_invoice.cancelled? || reserve_domain_invoice.failed?
        return render status: :unprocessable_entity, json: { message: 'Invoice is cancelled' }
      end

      case reserve_domain_invoice.reserve_paid_domains
      when :reserved
        render status: :ok, json: { message: 'Payment processed' }
      when :already_paid
        render status: :ok, json: { message: 'Invoice already paid' }
      else
        render status: :unprocessable_entity, json: { message: 'Failed to reserve domains' }
      end
    end

    private

    def find_reserve_domain_invoice
      return if params[:reference_number].blank?

      ReserveDomainInvoice.find_by(reference_no: params[:reference_number])
    end

    def set_audit_context
      ::PaperTrail.request(whodunnit: 'EIS billing payment') do
        ReservedDomain::Audit.set(source: 'eis_billing', reason: nil,
                                  reason_note: nil, registrar_id: nil) { yield }
      end
    end
  end
end
