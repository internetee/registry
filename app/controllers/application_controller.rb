class ApplicationController < ActionController::Base
  check_authorization unless: :devise_controller?

  # Prevent CSRF attacks by raising an exception.
  # For APIs, you may want to use :null_session instead.
  protect_from_forgery with: :exception

  before_action do
    resource = controller_name.singularize.to_sym
    method = "#{resource}_params"
    params[resource] &&= send(method) if respond_to?(method, true)
  end

  rescue_from CanCan::AccessDenied do |exception|
    redirect_to current_root_url, alert: exception.message
  end

  helper_method :registrant_request?, :registrar_request?, :admin_request?, :current_root_url
  helper_method :available_languages

  def registrant_request?
    request.path.match(/^\/registrant/)
  end

  def registrar_request?
    request.path.match(/^\/registrar/)
  end

  def admin_request?
    request.path.match(/^\/admin/)
  end

  def current_root_url
    if registrar_request?
      registrar_root_url
    elsif registrant_request?
      registrant_login_url
    elsif admin_request?
      admin_root_url
    end
  end

  def after_sign_in_path_for(_resource)
    rt = session[:user_return_to].to_s.presence
    login_paths = [admin_login_path, registrar_login_path, '/login']
    return rt if rt && !login_paths.include?(rt)
    current_root_url
  end

  def after_sign_out_path_for(_resource)
    if registrar_request?
      registrar_login_url
    elsif registrant_request?
      registrant_login_url
    elsif admin_request?
      admin_login_url
    end
  end

  def info_for_paper_trail
    { uuid: request.uuid }
  end

  def user_for_paper_trail
    user_log_str(current_user)
  end

  def depp_current_user
    @depp_current_user ||= Depp::User.new(
      tag: current_user.username,
      password: current_user.password
    )
  end

  def user_log_str(user)
    user.nil? ? 'public' : user.id_role_username
  end

  def comma_support_for(parent_key, key)
    return if params[parent_key].blank?
    return if params[parent_key][key].blank?
    params[parent_key][key].sub!(/,/, '.')
  end

  private

  def available_languages
    { en: 'English', et: 'Estonian' }.invert
  end
end
