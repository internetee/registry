class Registrar::SessionsController < Devise::SessionsController
  layout 'registrar/application'
  helper_method :depp_controller?
  def depp_controller?
    false
  end

  before_action :check_ip

  def login
    @depp_user = Depp::User.new
  end

  # rubocop:disable Metrics/PerceivedComplexity
  # rubocop:disable Metrics/CyclomaticComplexity
  # rubocop:disable Metrics/MethodLength
  # rubocop:disable Metrics/AbcSize
  def create
    @depp_user = Depp::User.new(params[:depp_user].merge(pki: !(Rails.env.development? || Rails.env.test?)))

    if @depp_user.pki && request.env['HTTP_SSL_CLIENT_S_DN_CN'].blank?
      @depp_user.errors.add(:base, :webserver_missing_user_name_directive)
    end

    if @depp_user.pki && request.env['HTTP_SSL_CLIENT_CERT'].blank?
      @depp_user.errors.add(:base, :webserver_missing_client_cert_directive)
    end

    if @depp_user.pki && request.env['HTTP_SSL_CLIENT_S_DN_CN'] == '(null)'
      @depp_user.errors.add(:base, :webserver_user_name_directive_should_be_required)
    end

    if @depp_user.pki && request.env['HTTP_SSL_CLIENT_CERT'] == '(null)'
      @depp_user.errors.add(:base, :webserver_client_cert_directive_should_be_required)
    end

    @api_user = ApiUser.find_by(username: params[:depp_user][:tag], password: params[:depp_user][:password])

    unless @api_user
      @depp_user.errors.add(:base, t(:no_such_user))
      render 'login' and return
    end

    if @depp_user.pki
      unless @api_user.registrar_pki_ok?(request.env['HTTP_SSL_CLIENT_CERT'], request.env['HTTP_SSL_CLIENT_S_DN_CN'])
        @depp_user.errors.add(:base, :invalid_cert)
      end
    end

    if @depp_user.errors.none?
      if @api_user.active?
        sign_in @api_user
        redirect_to registrar_root_url
      else
        @depp_user.errors.add(:base, :not_active)
        render 'login'
      end
    else
      render 'login'
    end
  end
  # rubocop:enable Metrics/MethodLength
  # rubocop:enable Metrics/AbcSize

  def switch_user
    @api_user = ApiUser.find(params[:id])

    unless Rails.env.development?
      unless @api_user.registrar.registrar_ip_white?(request.ip)
        flash[:alert] = I18n.t(:ip_is_not_whitelisted)
        redirect_to :back and return
      end
    end

    sign_in @api_user if @api_user.identity_code == current_user.identity_code

    redirect_to registrar_root_url
  end
  # rubocop:enable Metrics/CyclomaticComplexity
  # rubocop:enable Metrics/PerceivedComplexity

  def id
    @user = ApiUser.find_by_idc_data(request.env['SSL_CLIENT_S_DN'])

    if @user
      sign_in(@user, event: :authentication)
      redirect_to registrar_root_url
    else
      flash[:alert] = t('no_such_user')
      redirect_to registrar_login_url
    end
  end

  def login_mid
    @user = User.new
  end

  # rubocop:disable Metrics/MethodLength
  def mid
    phone = params[:user][:phone]
    endpoint = "#{ENV['sk_digi_doc_service_endpoint']}"
    client = Digidoc::Client.new(endpoint)
    client.logger = Rails.application.config.logger unless Rails.env.test?

    # country_codes = {'+372' => 'EST'}
    phone.gsub!('+372', '')
    response = client.authenticate(
      phone: "+372#{phone}",
      message_to_display: 'Authenticating',
      service_name: ENV['sk_digi_doc_service_name'] || 'Testing'
    )

    if response.faultcode
      render json: { message: response.detail.message }, status: :unauthorized
      return
    end

    @user = find_user_by_idc(response.user_id_code)

    if @user.persisted?
      session[:user_id_code] = response.user_id_code
      session[:mid_session_code] = client.session_code

      render json: {
        message: t(:confirmation_sms_was_sent_to_your_phone_verification_code_is, { code: response.challenge_id })
      }, status: :ok
    else
      render json: { message: t(:no_such_user) }, status: :unauthorized
    end
  end
  # rubocop:enable Metrics/MethodLength

  # rubocop: disable Metrics/AbcSize
  # rubocop: disable Metrics/CyclomaticComplexity
  # rubocop: disable Metrics/MethodLength
  def mid_status
    endpoint = "#{ENV['sk_digi_doc_service_endpoint']}"
    client = Digidoc::Client.new(endpoint)
    client.logger = Rails.application.config.logger unless Rails.env.test?
    client.session_code = session[:mid_session_code]
    auth_status = client.authentication_status

    case auth_status.status
    when 'OUTSTANDING_TRANSACTION'
      render json: { message: t(:check_your_phone_for_confirmation_code) }, status: :ok
    when 'USER_AUTHENTICATED'
      @user = find_user_by_idc(session[:user_id_code])
      sign_in @user
      flash[:notice] = t(:welcome)
      flash.keep(:notice)
      render js: "window.location = '#{registrar_root_url}'"
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

  private

  def check_ip
    return if Rails.env.development?
    return if WhiteIp.registrar_ip_white?(request.ip)
    render text: t('access_denied') and return
  end
end
