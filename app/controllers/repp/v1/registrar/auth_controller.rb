module Repp
  module V1
    module Registrar
      class AuthController < BaseController
        skip_before_action :authenticate_user, only: :tara_callback
        skip_before_action :check_ip_restriction, only: :tara_callback

        api :GET, 'repp/v1/registrar/auth'
        desc 'check user auth info and return data'
        def index
          registrar = current_user.registrar
          unless client_certs_ok
            handle_non_epp_errors(current_user, 'Invalid certificate')
            return
          end

          render_success(data: auth_values_to_data(registrar: registrar))
        end

        api :POST, 'repp/v1/registrar/auth/tara_callback'
        desc 'check tara callback omniauth user info and return token'
        def tara_callback
          user = ApiUser.from_omniauth(auth_params)
          handle_non_epp_errors(user, I18n.t(:no_such_user)) and return unless user && user&.active

          token = Base64.urlsafe_encode64("#{user.username}:#{user.plain_text_password}")
          render_success(data: { token: token, username: user.username })
        end

        api :put, '/repp/v1/registrar/auth/switch_user'
        desc 'Switch session to another api user'
        def switch_user
          new_user = ApiUser.find(auth_params[:new_user_id])
          unless current_user.linked_with?(new_user)
            handle_non_epp_errors(new_user, 'Cannot switch to unlinked user')
            return
          end

          @current_user = new_user
          data = auth_values_to_data(registrar: current_user.registrar)
          message = I18n.t('registrar.current_user.switch.switched', new_user: new_user)
          token = Base64.urlsafe_encode64("#{new_user.username}:#{new_user.plain_text_password}")
          render_success(data: { token: token, registrar: data }, message: message)
        end

        private

        def auth_params
          params.require(:auth).permit(:uid, :new_user_id)
        end

        def client_certs_ok
          current_user.pki_ok?(request.env['HTTP_SSL_CLIENT_CERT'],
                               request.env['HTTP_SSL_CLIENT_S_DN_CN'], api: false)
        end
      end
    end
  end
end
