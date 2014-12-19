class Admin::DashboardsController < AdminController
  authorize_resource class: false

  def show; end
end
