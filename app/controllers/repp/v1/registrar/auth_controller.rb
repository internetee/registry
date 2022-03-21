module Repp
  module V1
    module Registrar
      class AuthController < BaseController
        api :GET, 'repp/v1/registrar/auth'
        desc 'check user auth info, track user last login datetime and return data'

        def index
          registrar = current_user.registrar

          data = set_values_to_data(registrar: registrar)

          render_success(data: data)
        end

        private

        def set_values_to_data(registrar:)
          data = current_user.as_json(only: %i[id username roles])
          data[:registrar_name] = registrar.name
          data
        end
      end
    end
  end
end