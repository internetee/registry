class ApplicationController < ActionController::Base
  # Prevent CSRF attacks by raising an exception.
  # For APIs, you may want to use :null_session instead.
  protect_from_forgery with: :exception

  before_action do
    resource = controller_name.singularize.to_sym
    method = "#{resource}_params"
    params[resource] &&= send(method) if respond_to?(method, true)
  end

  def after_sign_in_path_for(resource)
    if ENV['REGISTRY_ENV'] == 'admin' && resource.admin?
      (session[:user_return_to].nil?) ? admin_root_path : session[:user_return_to].to_s
    else
      (session[:user_return_to].nil?) ? client_root_path : session[:user_return_to].to_s
    end
  end
end
