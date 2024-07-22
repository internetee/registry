module Api
  module V1
    module BusinessRegistry
      class TokenController < ::Api::V1::BaseController
        before_action :set_cors_header
        before_action :find_reserved_domain
        before_action :authenticate, only: [:update]

        def update
          if @reserved_domain.token_expired?
            @reserved_domain.refresh_token
            render json: { message: "Token refreshed", token: @reserved_domain.access_token }, status: :ok
          else
            render json: { message: "Token is still valid", token: @reserved_domain.access_token }, status: :ok
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
          end
        end
      end
    end
  end
end
