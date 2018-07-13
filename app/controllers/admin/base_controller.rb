module Admin
  class BaseController < ApplicationController
    before_action :authenticate_admin_user!
    helper_method :head_title_sufix

    def head_title_sufix
      t(:admin_head_title_sufix)
    end

    private

    def current_ability
      @current_ability ||= Ability.new(current_admin_user)
    end

    def user_for_paper_trail
      current_admin_user ? current_admin_user.id_role_username : 'guest'
    end
  end
end