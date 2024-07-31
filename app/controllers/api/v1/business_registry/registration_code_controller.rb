module Api
  module V1
    module BusinessRegistry
      class RegistrationCodeController < ::Api::V1::BaseController
        before_action :set_cors_header
        before_action :find_reserved_domain
        before_action :authenticate, only: [:show]

        def show
          render json: { name: @reserved_domain.name, registration_code: @reserved_domain.password }, status: :ok
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
          else
            @reserved_domain = ReservedDomain.find_by(name: @reserved_domain_status.name)
            
            render json: { error: "Domain not found in reserved list" }, status: :not_found if @reserved_domain.nil?
          end
        end
      end
    end
  end
end
