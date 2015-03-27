class RegistrarController < ApplicationController
  before_action :authenticate_user!
  layout 'depp/application'
end
