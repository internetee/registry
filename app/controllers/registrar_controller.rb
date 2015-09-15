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
    # return if Rails.env.development?
    registrar_ip_whitelisted = current_user.registrar.registrar_ip_white?(request.ip)

    # api_ip_whitelisted = true
    # if current_user.can?(:create, :epp_request)
    #   api_ip_whitelisted = current_user.registrar.api_ip_white?(request.ip)
    # end

    return if registrar_ip_whitelisted # && api_ip_whitelisted
    flash[:alert] = t('ip_is_not_whitelisted')
    sign_out(current_user)
    redirect_to registrar_login_path and return
  end
  # rubocop:enable Metrics/PerceivedComplexity
  # rubocop:enable Metrics/CyclomaticComplexity

  helper_method :head_title_sufix
  def head_title_sufix
    t(:registrar_head_title_sufix)
  end

  private

  def current_ability
    @current_ability ||= Ability.new(current_user, request.remote_ip)
  end
end
