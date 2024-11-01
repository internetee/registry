module Api
  module V1
    module BusinessRegistry
      # DEPRECATED
      
      class RefreshTokenController < ::Api::V1::BaseController
        before_action :authenticate, only: [:update]
        
        include Concerns::CorsHeaders
        include Concerns::TokenAuthentication
        
        def update
          @reserved_domain_status.refresh_token
          render json: { message: "Token refreshed", token: @reserved_domain_status.access_token }, status: :ok
        end
      end
    end
  end
end
