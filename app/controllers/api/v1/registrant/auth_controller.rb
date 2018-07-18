require 'rails5_api_controller_backport'

module Api
  module V1
    module Registrant
      class AuthController < ActionController::API
        def eid
          login_params = set_eid_params

          render json: login_params
        end

        def set_eid_params
          params.permit(:ident, :first_name, :last_name, :country)
        end
      end
    end
  end
end
