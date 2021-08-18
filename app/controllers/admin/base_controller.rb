module Admin
  class BaseController < ApplicationController
    before_action :authenticate_admin_user!
    helper_method :head_title_sufix
    before_action :set_paper_trail_whodunnit

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

    def paginate?
      params[:results_per_page].to_i.positive?
    end

    def render_by_format(page, filename)
      respond_to do |format|
        format.html { render page }
        format.csv do
          raw_csv = @q.result.to_csv
          send_data raw_csv,
                    filename: "#{filename}_#{Time.zone.now.to_formatted_s(:number)}.csv",
                    type: "#{Mime[:csv]}; charset=utf-8"
        end
      end
    end
  end
end
