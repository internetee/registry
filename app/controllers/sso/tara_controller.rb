module Sso
  class TaraController < ApplicationController
    skip_authorization_check

    def registrant_callback
      user = RegistrantUser.find_or_create_by_omniauth_data(user_hash)
      callback(user, registrar: false)
    end

    def registrar_callback
      user = ApiUser.from_omniauth(user_hash)
      callback(user, registrar: true)
    end

    # rubocop:disable Style/AndOr
    def callback(user, registrar: true)
      session[:omniauth_hash] = user_hash
      (show error and return) unless user

      flash[:notice] = t(:signed_in_successfully)
      sign_in_and_redirect(registrar ? :registrar_user : :registrant_user, user)
    end
    # rubocop:enable Style/AndOr

    def cancel
      redirect_to root_path, notice: t(:sign_in_cancelled)
    end

    def show_error(registrar: true)
      path = registrar ? new_registrar_user_session_url : new_registrant_user_session_url
      redirect_to path, alert: t(:no_such_user)
    end

    private

    def user_hash
      request.env['omniauth.auth']
    end
  end
end
