module Repp
  module V1
    module Registrar
      class LoginController < BaseController
        api :GET, 'repp/v1/registrar/login'
        desc 'check login user and return data'

        def index
          @login = current_user

          # rubocop:disable Style/AndOr
          render_success(data: nil) and return unless @login
          # rubocop:enable Style/AndOr

          data = @login.as_json()

          render_success(data: data)
        end
      end
    end
  end
end
