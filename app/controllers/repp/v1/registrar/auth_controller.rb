module Repp
  module V1
    module Registrar
      class AuthController < BaseController
        skip_before_action :authenticate_user, only: :tara_callback
        skip_before_action :check_ip_restriction, only: :tara_callback
        skip_before_action :validate_client_certs, only: :tara_callback

        api :GET, 'repp/v1/registrar/auth'
        desc 'check user auth info and return data'
        def index
          registrar = current_user.registrar
          render_success(data: auth_values_to_data(registrar: registrar))
        end

        api :POST, 'repp/v1/registrar/auth/tara_callback'
        desc 'check tara callback omniauth user info and return token'
        def tara_callback
          user = ApiUser.from_omniauth(auth_params)
          response = { code: 401, message: I18n.t(:no_such_user), data: {} }
          render(json: response, status: :unauthorized) and return unless user && user&.active

          token = Base64.urlsafe_encode64("#{user.username}:#{user.plain_text_password}")
          render_success(data: { token: token, username: user.username })
        end

        private

        def auth_params
          params.require(:auth).permit(:uid, :new_user_id)
        end
      end
    end
  end
end
