class Registrant::SessionsController < Devise::SessionsController
  layout 'registrant/application'

  def login_mid
    @user = User.new
  end

  def mid
    phone = params[:user][:phone]
    endpoint = (ENV['sk_digi_doc_service_endpoint']).to_s
    client = Digidoc::Client.new(endpoint)
    client.logger = Rails.application.config.logger unless Rails.env.test?

    # country_codes = {'+372' => 'EST'}
    response = client.authenticate(
      phone: "+372#{phone}",
      message_to_display: 'Authenticating',
      service_name: ENV['sk_digi_doc_service_name'] || 'Testing'
    )

    if response.faultcode
      render json: { message: response.detail.message }, status: :unauthorized
      return
    end

    @user = RegistrantUser.find_or_create_by_mid_data(response)

    if @user.persisted?
      session[:user_country] = response.user_country
      session[:user_id_code] = response.user_id_code
      session[:mid_session_code] = client.session_code

      render json: {
        message: t(:confirmation_sms_was_sent_to_your_phone_verification_code_is, code: response.challenge_id),
      }, status: :ok
    else
      render json: { message: t(:no_such_user) }, status: :unauthorized
    end
  end

  def mid_status
    endpoint = (ENV['sk_digi_doc_service_endpoint']).to_s
    client = Digidoc::Client.new(endpoint)
    client.logger = Rails.application.config.logger unless Rails.env.test?
    client.session_code = session[:mid_session_code]
    auth_status = client.authentication_status

    case auth_status.status
    when 'OUTSTANDING_TRANSACTION'
      render json: { message: t(:check_your_phone_for_confirmation_code) }, status: :ok
    when 'USER_AUTHENTICATED'
      @user = RegistrantUser.find_by(registrant_ident: "#{session[:user_country]}-#{session[:user_id_code]}")

      sign_in(:registrant_user, @user)
      flash[:notice] = t(:welcome)
      flash.keep(:notice)
      render js: "window.location = '#{registrant_root_path}'"
    when 'NOT_VALID'
      render json: { message: t(:user_signature_is_invalid) }, status: :bad_request
    when 'EXPIRED_TRANSACTION'
      render json: { message: t(:session_timeout) }, status: :bad_request
    when 'USER_CANCEL'
      render json: { message: t(:user_cancelled) }, status: :bad_request
    when 'MID_NOT_READY'
      render json: { message: t(:mid_not_ready) }, status: :bad_request
    when 'PHONE_ABSENT'
      render json: { message: t(:phone_absent) }, status: :bad_request
    when 'SENDING_ERROR'
      render json: { message: t(:sending_error) }, status: :bad_request
    when 'SIM_ERROR'
      render json: { message: t(:sim_error) }, status: :bad_request
    when 'INTERNAL_ERROR'
      render json: { message: t(:internal_error) }, status: :bad_request
    else
      render json: { message: t(:internal_error) }, status: :bad_request
    end
  end

  private

  def after_sign_in_path_for(_resource_or_scope)
    registrant_root_path
  end

  def after_sign_out_path_for(_resource_or_scope)
    new_registrant_user_session_path
  end

  def user_for_paper_trail
    current_registrant_user.present? ? current_registrant_user.id_role_username : 'anonymous'
  end
end
