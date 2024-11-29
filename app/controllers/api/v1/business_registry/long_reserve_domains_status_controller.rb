module Api
  module V1
    module BusinessRegistry
      class LongReserveDomainsStatusController < BaseController
        before_action :set_reserved_domain_invoice, only: [:show]
        
        def show
          result = @reserved_domain_invoice.invoice_state

          if result.paid?
            @reserved_domain_invoice.create_paid_reserved_domains
            render json: { status: 'paid', message: result.message, reserved_domains: @reserved_domain_invoice.build_reserved_domains_output }
          else
            render json: { status: result.status, message: result.message, names: @reserved_domain_invoice.domain_names }
          end
        end
        
        private

        def set_reserved_domain_invoice
          @reserved_domain_invoice = ReserveDomainInvoice.find_by(invoice_number: params[:invoice_number], metainfo: params[:user_unique_id])
          puts "reserved_domain_invoice: #{@reserved_domain_invoice.inspect}"
          raise ActiveRecord::RecordNotFound, 'Reserved domain invoice not found' if @reserved_domain_invoice.nil?
        end
      end
    end
  end
end
