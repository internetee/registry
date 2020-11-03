# frozen_string_literal: true

module Admin
  class MassActionsController < BaseController
    authorize_resource

    # GET /admin/disputes
    def index; end

    # POST /admin/disputes
    def create
      res = MassAction.process(params[:mass_action], params[:entry_list].path)
      backlog = "#{params[:mass_action]} done for #{res[:ok].join(',')}.\n" \
               "Failed: objects: #{res[:fail].join(',')}"

      redirect_to(admin_mass_actions_path, notice: backlog)
    end
  end
end
