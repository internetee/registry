class AdminController < ApplicationController
  before_action :verify_admin

  def verify_admin
    redirect_to client_root_path unless current_user.try(:admin?)
  end
end
