module Api
  module V1
    module BusinessRegistry
      class ReleaseController < ::Api::V1::BaseController
        before_action :set_cors_header
        before_action :find_reserved_domain
        before_action :authenticate, only: [:destroy]

        def destroy
          if @reserved_domain_status.token_expired?
            render json: { error: "Token expired. Please refresh the token. TODO: provide endpoint" }, status: :unauthorized
          else
            if @reserved_domain_status.destroy
              EisBilling::SendReservedDomainCancellationInvoiceStatus.new(domain_name: domain_name, token: @reserved_domain_status.access_token).call
              render json: { message: "Domain '#{@reserved_domain.name}' has been successfully released" }, status: :ok
            else
              render json: { error: "Failed to release domain", details: @reserved_domain.errors.full_messages }, status: :unprocessable_entity
            end
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
            render json: { error: "Token expired" }, status: :unauthorized
          end
        end
      end
    end
  end
end
