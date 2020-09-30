class Registrar
  class TaraController < ApplicationController
    skip_authorization_check

    # rubocop:disable Style/AndOr
    def callback
      session[:omniauth_hash] = user_hash
      @api_user = ApiUser.from_omniauth(user_hash)

      if @api_user
        flash[:notice] = t(:signed_in_successfully)
        sign_in_and_redirect(:registrar_user, @api_user)
      else
        show_error and return
      end
    end
    # rubocop:enable Style/AndOr

    def cancel
      redirect_to root_path, notice: t(:sign_in_cancelled)
    end

    def show_error
      redirect_to new_registrar_user_session_url, alert: t(:no_such_user)
    end

    private

    def user_hash
      request.env['omniauth.auth']
    end
  end
end
