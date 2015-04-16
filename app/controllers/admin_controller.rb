class AdminController < ApplicationController
  layout 'admin/application'
  before_action :authenticate_user!
end
