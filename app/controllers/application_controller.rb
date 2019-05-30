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
    redirect_to root_url, alert: exception.message
  end

  helper_method :available_languages

  def info_for_paper_trail
    { uuid: request.uuid }
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