require 'serializers/repp/domain'

module Api
  module V1
    module AccreditationCenter
      class AuthController < BaseController
        def index
          login = @current_user
          registrar = @current_user.registrar

          data = set_values_to_data(login: login, registrar: registrar)

          render_success(data: data)
        end

        private

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
          data[:registrar_email] = registrar.email
          data[:code] = registrar.code
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
