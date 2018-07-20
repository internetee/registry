require 'rails5_api_controller_backport'
require 'auth_token/auth_token_creator'

module Api
  module V1
    module Registrant
      class AuthController < ActionController::API
        rescue_from(ActionController::ParameterMissing) do |parameter_missing_exception|
          error = {}
          error[parameter_missing_exception.param] = ['parameter is required']
          response = { errors: [error] }
          render json: response, status: :unprocessable_entity
        end

        def eid
          user = RegistrantUser.find_or_create_by_api_data(eid_params)
          token = create_token(user)

          if token
            render json: token
          else
            render json: { error: 'Cannot create generate session token'}
          end
        end

        private

        def eid_params
          [:ident, :first_name, :last_name].each_with_object(params) do |key, obj|
            obj.require(key)
          end
        end

        def create_token(user)
          token_creator = AuthTokenCreator.create_with_defaults(user)
          hash = token_creator.token_in_hash
          hash
        end
      end
    end
  end
end
