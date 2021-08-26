require 'serializers/repp/domain'

module Api
  module V1
    module AccreditationCenter
      class AuthController < ::Api::V1::AccreditationCenter::BaseController
        before_action :authenticate_user

        def index
        login = @current_user
        registrar = @current_user.registrar

        # rubocop:disable Style/AndOr
        render_success(data: nil) and return unless login
        # rubocop:enable Style/AndOr

        data = set_values_to_data(login: login, registrar: registrar)

        render_success(data: data)
      end

      private

      def authenticate_user
        username, password = Base64.urlsafe_decode64(basic_token).split(':')
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

      def set_values_to_data(login:, registrar:)
        data = login.as_json(only: %i[id
                                      username
                                      name
                                      uuid
                                      roles
                                      accreditation_date
                                      accreditation_expire_date])
        data[:registrar_name] = registrar.name
        data[:registrar_reg_no] = registrar.reg_no
        data
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
