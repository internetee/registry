class ApplicationController < ActionController::Base
  # Prevent CSRF attacks by raising an exception.
  # For APIs, you may want to use :null_session instead.
  protect_from_forgery with: :exception

  before_action do
    resource = controller_name.singularize.to_sym
    method = "#{resource}_params"
    params[resource] &&= send(method) if respond_to?(method, true)
  end

  def after_sign_in_path_for(_resource)
    return session[:user_return_to].to_s if session[:user_return_to] && session[:user_return_to] != login_path
    admin_dashboard_path
  end

  def user_for_paper_trail
    if defined?(current_api_user) && current_api_user.present?
      "#{current_api_user.id}-api-#{current_api_user.username}"
    elsif current_user.present?
      "#{current_user.id}-#{current_user.username}"
    else
      'public'
    end
  end
end

class ApplicationController < ActionController::Base
  rescue_from CanCan::AccessDenied do |exception|
    redirect_to admin_dashboard_path, alert: exception.message
  end
end
