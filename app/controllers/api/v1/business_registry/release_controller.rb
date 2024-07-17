module Api
  module V1
    module BusinessRegistry
      class ReleaseController < ::Api::V1::BaseController
        before_action :set_cors_header
        # before_action :authenticate

        def destroy
          name = params[:name]
          render json: { message: "OK - #{name} | Release successful" }, status: :ok
        end

        private

        def set_cors_header
          response.headers['Access-Control-Allow-Origin'] = request.headers['Origin']
        end
      end
    end
  end
end
