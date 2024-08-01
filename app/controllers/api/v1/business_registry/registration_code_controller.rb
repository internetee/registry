module Api
  module V1
    module BusinessRegistry
      class RegistrationCodeController < ::Api::V1::BaseController
        before_action :authenticate, only: [:show]
        
        include Concerns::CorsHeaders
        include Concerns::TokenAuthentication

        def show
          render json: { name: @reserved_domain.name, registration_code: @reserved_domain.password }, status: :ok
        end
      end
    end
  end
end
