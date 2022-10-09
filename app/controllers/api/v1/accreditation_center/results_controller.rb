require 'serializers/repp/contact'

module Api
  module V1
    module AccreditationCenter
      class ResultsController < ::Api::V1::AccreditationCenter::BaseController
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
      end
    end
  end
end
