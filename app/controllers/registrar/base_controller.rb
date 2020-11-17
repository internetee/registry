class Registrar
  class BaseController < ApplicationController
    include Registrar::ApplicationHelper

    before_action :authenticate_registrar_user!
    before_action :check_ip_restriction
    helper_method :depp_controller?
    helper_method :head_title_sufix
    before_action :set_paper_trail_whodunnit

    protected

    def current_ability
      @current_ability ||= Ability.new(current_registrar_user, request.remote_ip)
    end

    private

    def check_ip_restriction
      ip_restriction = Authorization::RestrictedIP.new(request.remote_ip)
      allowed = ip_restriction.can_access_registrar_area?(current_registrar_user.registrar)

      if allowed
        return
      else
        sign_out current_registrar_user

        flash[:alert] = t('registrar.authorization.ip_not_allowed', ip: request.remote_ip)
        redirect_to new_registrar_user_session_url
      end
    end

    def depp_controller?
      false
    end

    def head_title_sufix
      t(:registrar_head_title_sufix)
    end

    def user_for_paper_trail
      current_registrar_user ? current_registrar_user.id_role_username : 'anonymous'
    end
  end
end
