require 'auth_token/auth_token_decryptor'

module Api
  module V1
    module AccreditationCenter
      class BaseController < ActionController::API
        # before_action :check_ip_whitelist

        rescue_from ActiveRecord::RecordNotFound, with: :show_not_found_error
        rescue_from ActiveRecord::RecordInvalid, with: :show_invalid_record_error
        rescue_from(ActionController::ParameterMissing) do |parameter_missing_exception|
          error = {}
          error[parameter_missing_exception.param] = ['parameter is required']
          response = { errors: [error] }
          render json: response, status: :unprocessable_entity
        end

        private

        # def check_ip_whitelist
        #   allowed_ips = ENV['accr_center_api_auth_allowed_ips'].to_s.split(',').map(&:strip)
        #   return if allowed_ips.include?(request.ip) || Rails.env.development? || Rails.env.staging?

        #   render json: { errors: [{ base: ['Not authorized'] }] }, status: :unauthorized
        # end

        def show_not_found_error
          render json: { errors: [{ base: ['Not found'] }] }, status: :not_found
        end

        def show_invalid_record_error(exception)
          render json: { errors: exception.record.errors }, status: :bad_request
        end
      end
    end
  end
end
