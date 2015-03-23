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

    country_codes = {'+372' => 'EST'}

    response = client.authenticate(
      :phone => "+372#{phone}",
      :message_to_display => 'Authenticating',
      :service_name => 'Testing'
    )

    @user = find_user_by_idc(response.user_id_code)

    if @user.persisted?
      session[:user_id_code] = response.user_id_code
      session[:mid_session_code] = client.session_code
      render json: { message: t('check_your_phone_for_confirmation_code') }, status: :ok
    else
      flash[:alert] = t('no_such_user')
      flash.keep(:alert)
      render js: "window.location = '#{registrar_login_mid_path}'"
    end

    # client.authentication_status
  end

  def mid_status
    client = Digidoc::Client.new
    client.session_code = session[:mid_session_code]
    auth_status = client.authentication_status

    # binding.pry
    # flash[:notice] = I18n.t('welcome')
    # flash.keep(:notice)

    # sign_in @user
    # render js: "window.location = '#{registrar_invoices_path}'"
    render json: { message: t('not_ok') }, status: :request_timeout
  end

  def find_user_by_idc(idc)
    return User.new unless idc
    ApiUser.find_by(identity_code: idc) || User.new
  end
end
