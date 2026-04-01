require 'serializers/repp/contact'

module Api
  module V1
    module AccreditationCenter
      class ResultsController < BaseController
        api :GET, 'api/v1/accreditation_center/results/:registrar_name'
        desc 'get results by registrar name'
        def show
          accr_users = []
          registrar = Registrar.find_by(name: params[:registrar_name])

          return render_error('Registrar not found', :not_found) if registrar.nil?

          registrar.api_users.where.not(accreditation_date: nil).each do |u|
            accr_users << u
          end

          render_success(data: { registrar_users: accr_users })
        end

        api :GET, 'api/v1/accreditation_center/results/api_user/:username/:identity_code'
        desc 'get api user by username and identity code'
        def show_api_user
          user_api = User.find_by(username: params[:username], identity_code: params[:identity_code])

          return render_error('User not found', :not_found) if user_api.nil?
          return render_error('No accreditated yet', :not_found) if user_api.accreditation_date.nil?

          render_success(data: { user_api: user_api })
        end

        api :GET, 'api/v1/accreditation_center/results/list_accreditated_api_users'
        desc 'list all accreditated api users'
        def list_accreditated_api_users
          users = User.where.not(accreditation_date: nil)

          return render_error('Accreditated users not found', :not_found) if users.empty?


          render_success(data: { users: users })
        end
      end
    end
  end
end
