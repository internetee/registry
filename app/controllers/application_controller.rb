class ApplicationController < ActionController::Base
  # Prevent CSRF attacks by raising an exception.
  # For APIs, you may want to use :null_session instead.
  protect_from_forgery with: :exception

  def after_sign_in_path_for(resource)
    if current_user.admin?
      (session[:user_return_to].nil?) ? admin_root_path : session[:user_return_to].to_s
    else
      (session[:user_return_to].nil?) ? client_root_path : session[:user_return_to].to_s
    end
  end
end
