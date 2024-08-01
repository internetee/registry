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
      end
    end
  end
end
