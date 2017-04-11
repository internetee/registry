class Registrant::SessionsController < Devise::SessionsController
  layout 'registrant/application'

  def login
  end

  # rubocop: disable Metrics/AbcSize
  def id
    id_code, id_issuer = request.env['SSL_CLIENT_S_DN'], request.env['SSL_CLIENT_I_DN_O']
    id_code, id_issuer = 'test', RegistrantUser::ACCEPTED_ISSUER if Rails.env.development?

    @user = RegistrantUser.find_or_create_by_idc_data(id_code, id_issuer)
    if @user
      sign_in(@user, event: :authentication)
      redirect_to registrant_root_url
    else
      flash[:alert] = t('login_failed_check_id_card')
      redirect_to registrant_login_url
    end
  end
  # rubocop: enable Metrics/AbcSize

  def login_mid
    @user = User.new
  end

  # rubocop: disable Metrics/MethodLength
  def mid 
    phone = params[:user][:phone]
    endpoint = "#{ENV['sk_digi_doc_service_endpoint']}"
    client = Digidoc::Client.new(endpoint)
    client.logger = Rails.application.config.logger

    if Rails.env.test? && phone == "123"
      @user = ApiUser.find_by(identity_code: "14212128025")
      sign_in(@user, event: :authentication)
      return redirect_to registrant_root_url
    end

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
        message: t(:confirmation_sms_was_sent_to_your_phone_verification_code_is, { code: response.challenge_id })
      }, status: :ok
    else
      render json: { message: t(:no_such_user) }, status: :unauthorized
    end
  end
  # rubocop: enable Metrics/MethodLength

  # rubocop: disable Metrics/AbcSize
  # rubocop: disable Metrics/CyclomaticComplexity
  # rubocop: disable Metrics/MethodLength
  def mid_status
    endpoint = "#{ENV['sk_digi_doc_service_endpoint']}"
    client = Digidoc::Client.new(endpoint)
    client.logger = Rails.application.config.logger
    client.session_code = session[:mid_session_code]
    auth_status = client.authentication_status

    case auth_status.status
    when 'OUTSTANDING_TRANSACTION'
      render json: { message: t(:check_your_phone_for_confirmation_code) }, status: :ok
    when 'USER_AUTHENTICATED'
      @user = RegistrantUser.find_by(registrant_ident: "#{session[:user_country]}-#{session[:user_id_code]}")

      sign_in @user
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
  # rubocop: enable Metrics/AbcSize
  # rubocop: enable Metrics/CyclomaticComplexity
  # rubocop: enable Metrics/MethodLength

  def find_user_by_idc(idc)
    return User.new unless idc
    ApiUser.find_by(identity_code: idc) || User.new
  end
end
