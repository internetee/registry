module Api
  module V1
    module BusinessRegistry
      class StatusController < ::Api::V1::BaseController
        before_action :set_cors_header
        before_action :authenticate, only: [:create]
        before_action :find_reserved_domain

        def show
          domain_name = @reserved_domain_status.name
          token = @reserved_domain_status.access_token

          result = EisBilling::GetReservedDomainInvoiceStatus.new(domain_name: domain_name, token: token).call
          if result.status_code_success

            if result.paid?
              @reserved_domain_status.paid!
              reserved_domain = ReservedDomain.find_by(name: domain_name)

              if reserved_domain.nil?
                reserved_domain = ReservedDomain.new(name: domain_name)
                reserved_domain.save!
              end

              render json: { invoice_status: result.status, reserved_domain: reserved_domain.name, password: reserved_domain.password }, status: :ok
            else
              render json: { invoice_status: result.status }, status: :ok
            end

          else
            render json: { error: "Failed to get domain status", details: result.details }, status: :unprocessable_entity
          end
        end

        private

        def set_cors_header
          allowed_origins = ENV['ALLOWED_ORIGINS'].split(',')
          if allowed_origins.include?(request.headers['Origin'])
            response.headers['Access-Control-Allow-Origin'] = request.headers['Origin']
          else
            render json: { error: "Unauthorized origin" }, status: :unauthorized
          end
        end

        def find_reserved_domain
          token = request.headers['Authorization']&.split(' ')&.last
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
