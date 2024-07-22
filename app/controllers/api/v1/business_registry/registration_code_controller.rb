module Api
  module V1
    module BusinessRegistry
      class RegistrationCodeController < ::Api::V1::BaseController
        before_action :set_cors_header
        before_action :find_reserved_domain
        before_action :authenticate, only: [:show]

        def show
          if @reserved_domain.token_expired?
            render json: { error: "Token expired" }, status: :unauthorized
          else
            render json: { name: @reserved_domain.name, registration_code: @reserved_domain.password }, status: :ok
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
          @reserved_domain = ReservedDomain.find_by(access_token: token)
          if @reserved_domain.nil?
            render json: { error: "Invalid token" }, status: :unauthorized
          elsif @reserved_domain.token_expired?
            render json: { error: "Token expired" }, status: :unauthorized
          end
        end
      end
    end
  end
end
