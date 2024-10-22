module Api
  module V1
    module BusinessRegistry
      class StatusController < BaseController
        before_action :authenticate, only: [:create]
        skip_before_action :find_reserved_domain, only: [:show]
        before_action :find_reserved_domain_status, only: [:show]

        def show
          result = fetch_domain_status
          result.status_code_success ? handle_successful_status(result) : render_error("Failed to get domain status", :unprocessable_entity, result.details)
        end

        private

        def fetch_domain_status = EisBilling::GetReservedDomainInvoiceStatus.new(
                                    domain_name: @reserved_domain_status.name,
                                    token: @reserved_domain_status.access_token
                                  ).call

        def handle_successful_status(result)
          return handle_paid_status if result.paid?

          render_success({ 
            invoice_status: result.status,
            domain_name: @reserved_domain_status.name,
            linkpay: @reserved_domain_status.linkpay_url
          })
        end

        def find_or_create_reserved_domain = ReservedDomain.find_or_create_by!(name: @reserved_domain_status.name)

        def extract_token_from_header = request.headers['Authorization']&.split(' ')&.last

        def handle_paid_status
          @reserved_domain_status.paid!
          reserved_domain = find_or_create_reserved_domain
          
          render_success({
            invoice_status: 'paid',
            reserved_domain: reserved_domain.name,
            password: reserved_domain.password
          })
        end

        def find_reserved_domain_status
          token = extract_token_from_header
          @reserved_domain_status = ReservedDomainStatus.find_by(access_token: token)

          if @reserved_domain_status.nil?
            render json: { error: "Invalid token" }, status: :unauthorized
          elsif @reserved_domain_status.token_expired?
            render json: { error: "Token expired. Please refresh the token. TODO: provide endpoint" }, status: :unauthorized
          end
        end
      end
    end
  end
end
