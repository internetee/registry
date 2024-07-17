module Api
  module V1
    module BusinessRegistry
      class ReserveController < ::Api::V1::BaseController
        before_action :set_cors_header
        # before_action :authenticate

        def create
          name = params[:name]
          organization_code = params[:organization_code]
          render json: { message: "OK - #{name} | #{organization_code}" }, status: :created
        end

        private

        def set_cors_header
          response.headers['Access-Control-Allow-Origin'] = request.headers['Origin']
        end
      end
    end
  end
end
