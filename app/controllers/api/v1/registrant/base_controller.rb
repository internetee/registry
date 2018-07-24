require 'rails5_api_controller_backport'
require 'auth_token/auth_token_decryptor'

module API
  module V1
    module Registrant
      class BaseController < ActionController::API
        before_action :authenticate

        rescue_from(ActionController::ParameterMissing) do |parameter_missing_exception|
          error = {}
          error[parameter_missing_exception.param] = ['parameter is required']
          response = { errors: [error] }
          render json: response, status: :unprocessable_entity
        end

        private

        def bearer_token
          pattern = /^Bearer /
          header  = request.headers['Authorization']
          header.gsub(pattern, '') if header && header.match(pattern)
        end

        def authenticate
          decryptor = AuthTokenDecryptor.create_with_defaults(bearer_token)
          decryptor.decrypt_token

          if decryptor.valid?
            sign_in decryptor.user
          else
            render json: { error: 'Not authorized' }, status: 401
          end
        end
      end
    end
  end
end
