require 'auth_token/auth_token_decryptor'

module Api
  module V1
    module AccreditationCenter
      if Feature.allow_accr_endspoints?
        class BaseController < ActionController::API
          rescue_from ActiveRecord::RecordNotFound, with: :show_not_found_error
          rescue_from ActiveRecord::RecordInvalid, with: :show_invalid_record_error
          rescue_from(ActionController::ParameterMissing) do |parameter_missing_exception|
            error = {}
            error[parameter_missing_exception.param] = ['parameter is required']
            response = { errors: [error] }
            render json: response, status: :unprocessable_entity
          end

          private

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
end
