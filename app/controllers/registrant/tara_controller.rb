class Registrant
  class TaraController < ApplicationController
    skip_authorization_check

    # rubocop:disable Style/AndOr
    def callback
      session[:omniauth_hash] = user_hash
      @registrant_user = RegistrantUser.find_or_create_by_omniauth_data(user_hash)

      if @registrant_user
        flash[:notice] = t(:signed_in_successfully)
        sign_in_and_redirect(:registrant_user, @registrant_user)
      else
        show_error and return
      end
    end
    # rubocop:enable Style/AndOr

    def cancel
      redirect_to root_path, notice: t(:sign_in_cancelled)
    end

    def show_error
      redirect_to new_registrant_user_session_url, alert: t(:no_such_user)
    end

    private

    def user_hash
      request.env['omniauth.auth']
    end
  end
end
