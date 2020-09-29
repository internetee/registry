class Registrar
  class TaraController < ApplicationController
    skip_authorization_check

    def callback
      session[:omniauth_hash] = user_hash
      @api_user = ApiUser.from_omniauth(user_hash)

      return unless @api_user.persisted?

      sign_in_and_redirect(:registrar_user, @api_user)
    end

    # rubocop:disable Metrics/MethodLength
    # def create
    #   @user = User.new(create_params)
    #   check_for_tampering
    #   create_password
    #
    #   respond_to do |format|
    #     if @user.save
    #       format.html do
    #         sign_in(User, @user)
    #         redirect_to user_path(@user.uuid), notice: t(:created)
    #       end
    #     else
    #       format.html { render :callback }
    #     end
    #   end
    # end
    # rubocop:enable Metrics/MethodLength

    def cancel
      redirect_to root_path, notice: t(:sign_in_cancelled)
    end

    private

    # def create_params
    #   params.require(:user)
    #         .permit(:email, :identity_code, :country_code, :given_names, :surname,
    #                 :accepts_terms_and_conditions, :locale, :uid, :provider)
    # end

    # def create_password
    #   @user.password = Devise.friendly_token[0..20]
    # end

    def user_hash
      request.env['omniauth.auth']
    end

    def tara_logger
      @tara_logger ||= Logger.new(Rails.root.join('log', 'tara_auth4.log'))
    end
  end
end
