class Registrar::SessionsController < SessionsController
  layout 'registrar'

  def create
    @user = ApiUser.first if params[:user1]

    return redirect_to :back, alert: 'No user' if @user.blank?

    flash[:notice] = I18n.t('welcome')
    sign_in_and_redirect @user, event: :authentication
  end

  def login
  end

  def login_mid
    @user = User.new
  end

  def mid
    phone = params[:user][:phone]
    client = Digidoc::Client.new

    # country_codes = {'+372' => 'EST'}

    response = client.authenticate(
      phone: "+372#{phone}",
      message_to_display: 'Authenticating',
      service_name: 'Testing'
    )

    @user = find_user_by_idc(response.user_id_code)

    if @user.persisted?
      session[:user_id_code] = response.user_id_code
      session[:mid_session_code] = client.session_code
      render json: { message: t('check_your_phone_for_confirmation_code') }, status: :ok
    else
      render json: { message: t('no_such_user') }, status: :unauthorized
    end
  end

  # rubocop: disable Metrics/PerceivedComplexity
  # rubocop: disable Metrics/CyclomaticComplexity
  # rubocop: disable Metrics/MethodLength
  def mid_status
    client = Digidoc::Client.new
    client.session_code = session[:mid_session_code]
    auth_status = client.authentication_status

    case auth_status.status
    when 'OUTSTANDING_TRANSACTION'
      render json: { message: t('check_your_phone_for_confirmation_code') }, status: :ok
    when 'USER_AUTHENTICATED'
      @user = find_user_by_idc(session[:user_id_code])
      sign_in @user
      flash[:notice] = t('welcome')
      flash.keep(:notice)
      render js: "window.location = '#{registrar_invoices_path}'"
    when 'NOT_VALID'
      render json: { message: t('user_signature_is_invalid') }, status: :bad_request
    when 'EXPIRED_TRANSACTION'
      render json: { message: t('session_timeout') }, status: :bad_request
    when 'USER_CANCEL'
      render json: { message: t('user_cancelled') }, status: :bad_request
    when 'MID_NOT_READY'
      render json: { message: t('mid_not_ready') }, status: :bad_request
    when 'PHONE_ABSENT'
      render json: { message: t('phone_absent') }, status: :bad_request
    when 'SENDING_ERROR'
      render json: { message: t('sending_error') }, status: :bad_request
    when 'SIM_ERROR'
      render json: { message: t('sim_error') }, status: :bad_request
    when 'INTERNAL_ERROR'
      render json: { message: t('internal_error') }, status: :bad_request
    else
      render json: { message: t('internal_error') }, status: :bad_request
    end
  end
  # rubocop: enable Metrics/PerceivedComplexity
  # rubocop: enable Metrics/CyclomaticComplexity
  # rubocop: enable Metrics/MethodLength

  def find_user_by_idc(idc)
    return User.new unless idc
    ApiUser.find_by(identity_code: idc) || User.new
  end
end
