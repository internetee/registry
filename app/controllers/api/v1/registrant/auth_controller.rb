require 'rails5_api_controller_backport'
require 'auth_token/auth_token_creator'

module Api
  module V1
    module Registrant
      class AuthController < ActionController::API
        before_action :check_ip_whitelist

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
            render json: { errors: [{ base: ['Cannot create generate session token'] }] }
          end
        end

        private

        def eid_params
          required_params = %i[ident first_name last_name]
          required_params.each_with_object(params) do |key, obj|
            obj.require(key)
          end

          params.permit(required_params)
        end

        def create_token(user)
          token_creator = AuthTokenCreator.create_with_defaults(user)
          hash = token_creator.token_in_hash
          hash
        end

        def check_ip_whitelist
          allowed_ips = ENV['registrant_api_auth_allowed_ips'].to_s.split(',').map(&:strip)
          return if allowed_ips.include?(request.ip) || Rails.env.development?

          render json: { errors: [{ base: ['Not authorized'] }] }, status: :unauthorized
        end
      end
    end
  end
end
