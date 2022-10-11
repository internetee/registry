require 'serializers/repp/contact'

module Api
  module V1
    module AccreditationCenter
      class ResultsController < ::Api::V1::AccreditationCenter::BaseController
        PAYLOAD_KEY = 'secret'.freeze
        PAYLOAD_VALUE = 'accr'.freeze

        before_action :authorized

        def show
          accr_users = []
          registrar = Registrar.find_by(name: params[:registrar_name])

          return render json: { errors: 'Registrar not found' }, status: :not_found if registrar.nil?

          registrar.api_users.where.not(accreditation_date: nil).each do |u|
            accr_users << u
          end

          render json: { code: 1000, registrar_users: accr_users }
        end

        def show_api_user
          user_api = User.find_by(username: params[:username], identity_code: params[:identity_code])

          return render json: { errors: 'User not found' }, status: :not_found if user_api.nil?

          return render json: { errors: 'No accreditated yet' }, status: :not_found if user_api.accreditation_date.nil?

          render json: { code: 1000, user_api: user_api }
        end

        def list_accreditated_api_users
          users = User.where.not(accreditation_date: nil)

          return render json: { errors: 'Accreditated users not found' }, status: :not_found if users.empty?

          render json: { code: 1000, users: users }
        end

        private

        def auth_header
          # { Authorization: 'Bearer <token>' }
          request.headers['Authorization']
        end

        def decoded_token
          return unless auth_header

          token = auth_header.split(' ')[1]
          begin
            JWT.decode(token, accr_secret, true, algorithm: 'HS256')
          rescue JWT::DecodeError
            nil
          end
        end

        def accr_secret
          ENV['accreditation_secret']
        end

        def accessable_service
          return decoded_token[0][PAYLOAD_KEY] == PAYLOAD_VALUE if decoded_token

          false
        end

        def logged_in?
          !!accessable_service
        end

        def authorized
          render json: { message: 'Access denied' }, status: :unauthorized unless logged_in?
        end
      end
    end
  end
end
