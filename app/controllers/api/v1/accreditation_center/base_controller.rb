require 'auth_token/auth_token_decryptor'

module Api
  module V1
    module AccreditationCenter
      class BaseController < ActionController::API
        before_action :check_feature_enabled, :authenticate_user

        rescue_from ActiveRecord::RecordNotFound, with: :show_not_found_error
        rescue_from ActiveRecord::RecordInvalid, with: :show_invalid_record_error
        rescue_from(ActionController::ParameterMissing) do |parameter_missing_exception|
          response = { errors: "Parameter #{parameter_missing_exception.param} is required" }
          render json: response, status: :unprocessable_entity
        end

        private

        def check_feature_enabled
          return if Feature.allow_accr_endspoints?

          render json: {
            errors: 'Accreditation Center API is not allowed'
          }, status: :forbidden
        end

        def show_not_found_error
          render json: { errors: 'Not found' }, status: :not_found
        end

        def show_invalid_record_error(exception)
          render json: { errors: exception.record.errors }, status: :bad_request
        end

        def authenticate_user
          username, password = Base64.strict_decode64(basic_token).split(':')
          @current_user ||= ApiUser.find_by(username: username, plain_text_password: password)

          return if @current_user

          raise(ArgumentError)
        rescue NoMethodError, ArgumentError
          @response = { code: 2202, message: 'Invalid authorization information' }
          render(json: @response, status: :unauthorized)
        end

        def basic_token
          pattern = /^Basic /
          header  = request.headers['Authorization']
          header = header.gsub(pattern, '') if header&.match(pattern)
          header.strip
        end
      end
    end
  end
end
