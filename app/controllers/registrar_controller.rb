class RegistrarController < ApplicationController
  before_action :authenticate_user!
  layout 'registrar/application'

  helper_method :depp_controller?
  def depp_controller?
    false
  end
end
