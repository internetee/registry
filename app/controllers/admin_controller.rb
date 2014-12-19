class AdminController < ApplicationController
  before_action :authenticate_user!
  check_authorization
end
