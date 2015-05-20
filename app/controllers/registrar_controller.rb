class RegistrarController < ApplicationController
  before_action :authenticate_user!, :check_ip
  # before_action :check_ip
  layout 'registrar/application'

  include Registrar::ApplicationHelper

  helper_method :depp_controller?
  def depp_controller?
    false
  end

  def check_ip
    return unless current_user
    return if current_user.registrar.registrar_ip_white?(request.ip)
    flash[:alert] = t('access_denied')
    sign_out(current_user)
    redirect_to registrar_login_path and return
  end

  helper_method :head_title_sufix
  def head_title_sufix
    t(:registrar_head_title_sufix)
  end
end
