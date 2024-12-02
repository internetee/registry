module Api
  module V1
    module BusinessRegistry
      class BaseController < ::Api::V1::BaseController
        class AuthorizationError < StandardError; end
        
        before_action :authenticate_token!
        
        rescue_from AuthorizationError, with: :render_unauthorized
        
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

        def authenticate_token!
          token = request.headers['Authorization']&.split(' ')&.last
          unless valid_token?(token)
            raise AuthorizationError, 'Invalid or missing API token'
          end
        end

        def valid_token?(token)
          return false unless token
          # Replace this with your actual token validation logic
          # For example, check against configured API tokens
          allowed_tokens.include?(token)
        end

        def allowed_tokens
          ENV['business_registry_api_tokens'].to_s.split(',').map(&:strip)
        end

        def render_unauthorized
          render_error('Unauthorized', :unauthorized)
        end
      end
    end
  end
end
