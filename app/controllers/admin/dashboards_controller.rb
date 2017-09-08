module Admin
  class DashboardsController < BaseController
    authorize_resource class: false

    def show
      redirect_to [:admin, :domains] if can? :show, Domain
    end
  end
end
