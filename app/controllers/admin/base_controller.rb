module Admin
  class BaseController < ApplicationController
    before_action :authenticate_admin_user!
    before_action :set_current_user_whodunnit
    helper_method :head_title_sufix

    def head_title_sufix
      t(:admin_head_title_sufix)
    end

    private

    def current_ability
      @current_ability ||= Ability.new(current_admin_user)
    end

    def user_for_paper_trail
      current_admin_user ? current_admin_user.id_role_username : 'anonymous'
    end

    def set_current_user_whodunnit
      User.whodunnit = current_admin_user ? current_admin_user.id_role_username : 'anonymous'
    end

    def catch_version_page
      per_page = 7
      counter = @versions_map.index(@version.id) + 1
      page = counter / per_page
      page += 1 if (counter % per_page) != 0
      page
    end
  end
end
