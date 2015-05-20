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
    unless current_user.is_a? ApiUser
      sign_out(current_user)
      return
    end

    return if current_user.registrar.registrar_ip_white?(request.ip)
    flash[:alert] = t('ip_is_not_whitelisted')
    sign_out(current_user)
    redirect_to registrar_login_path and return
  end

  helper_method :head_title_sufix
  def head_title_sufix
    t(:registrar_head_title_sufix)
  end
end
