class Registrar
  class TaraController < ApplicationController
    skip_authorization_check

    def callback
      session[:omniauth_hash] = user_hash
      @api_user = ApiUser.from_omniauth(user_hash)

      return unless @api_user.persisted?

      sign_in_and_redirect(:registrar_user, @api_user)
    end

    def cancel
      redirect_to root_path, notice: t(:sign_in_cancelled)
    end

    private

    def user_hash
      request.env['omniauth.auth']
    end
  end
end
