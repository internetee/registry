class RegistrarController < ApplicationController
  before_action :authenticate_user!, :check_ip
  layout 'registrar/application'

  include Registrar::ApplicationHelper

  helper_method :depp_controller?
  def depp_controller?
    false
  end

  # rubocop:disable Metrics/PerceivedComplexity
  # rubocop:disable Metrics/CyclomaticComplexity
  def check_ip
    return unless current_user
    unless current_user.is_a? ApiUser
      sign_out(current_user)
      return
    end
    return if Rails.env.development?
    riw = current_user.registrar.registrar_ip_white?(request.ip)

    aiw = true
    if current_user.can_make_api_calls?
      aiw = current_user.registrar.api_ip_white?(request.ip)
    end

    return if riw && aiw
    flash[:alert] = t('access_denied')
    sign_out(current_user)
    redirect_to registrar_login_path and return
  end
  # rubocop:enable Metrics/PerceivedComplexity
  # rubocop:enable Metrics/CyclomaticComplexity

  helper_method :head_title_sufix
  def head_title_sufix
    t(:registrar_head_title_sufix)
  end
end
