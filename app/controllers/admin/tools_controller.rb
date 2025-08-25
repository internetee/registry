module Admin
  class ToolsController < BaseController
    before_action :authorize_admin

    # GET /admin/tools
    def index; end

    private

    def authorize_admin
      authorize! :access, :tools
    end
  end
end
