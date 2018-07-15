module Admin
  class DashboardController < BaseController
    authorize_resource class: false

    def show; end
  end
end