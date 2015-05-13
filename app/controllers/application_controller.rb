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
      registrar_root_url
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

  def user_for_paper_trail
    if defined?(current_user) && current_user.present?
      # Most of the time it's not loaded in correct time because PaperTrail before filter kicks in
      # before current_user is defined. PaperTrail is triggered also at current_user
      api_user_log_str(current_user)
    elsif current_user.present?
      "#{current_user.id}-#{current_user.username}"
    else
      'public'
    end
  end

  def depp_current_user
    @depp_current_user ||= Depp::User.new(
      tag: current_user.username,
      password: current_user.password
    )
  end

  def api_user_log_str(user)
    if user.present?
      "#{user.id}-api-#{user.username}"
    else
      'api-public'
    end
  end
end
