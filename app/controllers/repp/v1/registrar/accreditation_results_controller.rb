module Repp
  module V1
    module Registrar
      class AccreditationResultsController < ActionController::API
        before_action :authenticate_admin

        # api :POST, 'repp/v1/registrar/push_results'
        api :GET, 'repp/v1/registrar/accreditation/push_results'
        desc 'added datetime results'

        def index
          @login = @current_user

          # rubocop:disable Style/AndOr
          render_success(data: nil) and return unless @login
          # rubocop:enable Style/AndOr

          data = @login
          render_success(data: data)
        end

        # def create
          # @login = current_user
          # registrar = current_user.registrar

          # rubocop:disable Style/AndOr
          # render_success(data: nil) and return unless @login
          # rubocop:enable Style/AndOr

          # user = ApiUser.find(params[:user_id])
          # user.accreditation_date = Date.now
          # user.save



        #   data = @login.as_json(only: %i[id username name reg_no uuid roles accreditation_date accreditation_expire_date])
        #   data[:registrar_name] = registrar.name
        #   data[:registrar_reg_no] = registrar.reg_no

        #   render_success(data: data)
        # end

        private

        def authenticate_admin
          # TODO: ADD MORE CONDITIONS FOR ACCR ADMIN REQUESTS
          username, password = Base64.urlsafe_decode64(basic_token).split(':')
          @current_user ||= User.find_by(username: username, plain_text_password: password)

          return if @current_user
          # return if @current_user.roles.include? "admin"

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

        def render_success(code: nil, message: nil, data: nil)
          @response = { code: code || 1000, message: message || 'Command completed successfully',
                        data: data || {} }

          render(json: @response, status: :ok)
        end
      end
    end
  end
end
