module EisBilling
  class BaseController < ApplicationController
    protect_from_forgery with: :null_session
    skip_authorization_check # Temporary solution
    # skip_before_action :verify_authenticity_token # Temporary solution
    before_action :persistent
    before_action :authorized

    def encode_token(payload)
      JWT.encode(payload, ENV['secret_word'])
    end

    def auth_header
      # { Authorization: 'Bearer <token>' }
      request.headers['Authorization']
    end

    def decoded_token
      if auth_header
        token = auth_header.split(' ')[1]
        # header: { 'Authorization': 'Bearer <token>' }
        begin
          JWT.decode(token, ENV['secret_word'], true, algorithm: 'HS256')
        rescue JWT::DecodeError
          nil
        end
      end
    end

    def accessable_service
      if decoded_token
        decoded_token[0]['data'] == ENV['secret_access_word']
      end
    end

    def logged_in?
      !!accessable_service
    end

    def authorized
      render json: { message: 'Access denied' }, status: :unauthorized unless logged_in?
    end

    def logger
      Rails.logger
    end

    def logger
      @logger ||= Rails.logger
    end

    def persistent
      return true if Feature.billing_system_integrated?

      render json: { message: "We don't work yet!" }, status: :unauthorized
    end
  end
end
