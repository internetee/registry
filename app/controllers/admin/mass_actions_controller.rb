# frozen_string_literal: true

module Admin
  class MassActionsController < BaseController
    authorize_resource

    # GET /admin/mass_actions
    def index; end

    # POST /admin/mass_actions
    def create
      res = MassAction.process(params[:mass_action], params[:entry_list].path)
      backlog = "#{params[:mass_action]} completed for #{res[:ok]}.\n" \
               "Failed: objects: #{res[:fail]}"

      redirect_to(admin_mass_actions_path, notice: backlog)
    end
  end
end
