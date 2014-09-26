class ClientController < ApplicationController
  helper_method :current_registrar

  def current_registrar
    return Registrar.find(session[:current_user_registrar_id]) if current_user.admin?
    current_user.registrar
  end
end
