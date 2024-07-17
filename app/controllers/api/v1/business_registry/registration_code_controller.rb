module Api
  module V1
    module BusinessRegistry
      class RegistrationCodeController < ::Api::V1::BaseController
        before_action :set_cors_header
        # before_action :authenticate

        def show
          name = params[:name]
          render json: { message: "OK - #{name} | Registration code: some code" }, status: :ok
        end

        private

        def set_cors_header
          response.headers['Access-Control-Allow-Origin'] = request.headers['Origin']
        end
      end
    end
  end
end
