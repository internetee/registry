class Registrar
  class BaseController < ApplicationController
    include Registrar::ApplicationHelper

    before_action :authenticate_user!
    before_action :check_ip_restriction
    helper_method :depp_controller?
    helper_method :head_title_sufix

    protected

    def current_ability
      @current_ability ||= Ability.new(current_user, request.remote_ip)
    end

    private

    def check_ip_restriction
      ip_restriction = Authorization::RestrictedIP.new(request.ip)
      allowed = ip_restriction.can_access_registrar_area?(current_user.registrar)

      return if allowed

      sign_out current_user

      flash[:alert] = t('registrar.authorization.ip_not_allowed', ip: request.ip)
      redirect_to registrar_login_url
    end

    def depp_controller?
      false
    end

    def head_title_sufix
      t(:registrar_head_title_sufix)
    end
  end
end
