class AdminController < ApplicationController
  before_action :authenticate_user!
end
