# frozen_string_literal: true

module Admin
  class MassActionsController < BaseController
    before_action :authorize_admin

    # GET /admin/mass_actions
    def index; end

    # POST /admin/mass_actions
    def create
      res = MassAction.process(params[:mass_action], params[:entry_list].path)
      notice = if res
                 "#{params[:mass_action]} completed for #{res[:ok]}.\n" \
                 "Failed: objects: #{res[:fail]}"
               else
                 "Dataset integrity validation failed for #{params[:mass_action]}"
               end

      redirect_to(admin_mass_actions_path, notice: notice)
    end

    def authorize_admin
      authorize! :manage, :mass_actions
    end
  end
end
