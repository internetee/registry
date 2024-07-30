module Api
  module V1
    module BusinessRegistry
      class RefreshTokenController < ::Api::V1::BaseController
        # before_action :set_cors_header
        before_action :find_reserved_domain
        # before_action :authenticate, only: [:update]

        def update
          @reserved_domain_status.refresh_token
          render json: { message: "Token refreshed", token: @reserved_domain_status.access_token }, status: :ok
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
          
          render json: { error: "Invalid token" }, status: :unauthorized if @reserved_domain_status.nil?
        end
      end
    end
  end
end
