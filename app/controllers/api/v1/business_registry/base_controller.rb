module Api
  module V1
    module BusinessRegistry
      class BaseController < ::Api::V1::BaseController
        include Concerns::CorsHeaders
        include Concerns::TokenAuthentication

        before_action :authenticate

        protected

        def render_error(message, status, details = nil)
          error_response = { error: message }
          error_response[:details] = details if details
          render json: error_response, status: status
        end

        def render_success(data, status = :ok) = render(json: data, status: status)

        def allowed_ips
          ENV['business_registry_allowed_ips'].to_s.split(',').map(&:strip)
        end

        private

        def extract_token_from_header = request.headers['Authorization']&.split(' ')&.last

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
