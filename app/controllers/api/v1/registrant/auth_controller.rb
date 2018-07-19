require 'rails5_api_controller_backport'
require 'auth_token'

module Api
  module V1
    module Registrant
      class AuthController < ActionController::API
        def eid
          login_params = set_eid_params

          user = RegistrantUser.find_or_create_by_api_data(login_params)

          unless user.valid?
            render json: user.errors, status: :bad_request
          else
            token = create_token(user)
            render json: token
          end
        end

        def set_eid_params
          params.permit(:ident, :first_name, :last_name)
        end

        def create_token(user)
          token = AuthToken.new
          hash = token.generate_token(user)
          hash
        end
      end
    end
  end
end
