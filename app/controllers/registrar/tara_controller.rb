require 'tampering_detected'

class TaraController < ApplicationController
  rescue_from Errors::TamperingDetected do
    redirect_to root_url, alert: t('auth.tara.tampering')
  end

  def callback
    session[:omniauth_hash] = user_hash

    @user = User.from_omniauth(user_hash)

    return unless @user.persisted?

    sign_in(User, @user)
    redirect_to user_path(@user.uuid), notice: t('devise.sessions.signed_in')
  end

  # rubocop:disable Metrics/MethodLength
  def create
    @user = User.new(create_params)
    check_for_tampering
    create_password

    respond_to do |format|
      if @user.save
        format.html do
          sign_in(User, @user)
          redirect_to user_path(@user.uuid), notice: t(:created)
        end
      else
        format.html { render :callback }
      end
    end
  end
  # rubocop:enable Metrics/MethodLength

  def cancel
    redirect_to root_path, notice: t(:sign_in_cancelled)
  end

  private

  def create_params
    params.require(:user)
          .permit(:email, :identity_code, :country_code, :given_names, :surname,
                  :accepts_terms_and_conditions, :locale, :uid, :provider)
  end

  def check_for_tampering
    return unless @user.tampered_with?(session[:omniauth_hash])

    session.delete(:omniauth_hash)
    raise Errors::TamperingDetected
  end

  def create_password
    @user.password = Devise.friendly_token[0..20]
  end

  def user_hash
    request.env['omniauth.auth']
  end
end
