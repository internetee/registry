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
    redirect_to admin_dashboard_path, alert: exception.message
  end

  def after_sign_in_path_for(_resource)
    if session[:user_return_to] && session[:user_return_to] != login_path
      return session[:user_return_to].to_s 
    end
    admin_dashboard_path
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

  def api_user_log_str(user)
    if user.present?
      "#{user.id}-api-#{user.username}"
    else
      'api-public'
    end
  end
end
