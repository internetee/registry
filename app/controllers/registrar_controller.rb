class RegistrarController < ApplicationController
  before_action :authenticate_user!
  layout 'registrar/application'

  include Registrar::ApplicationHelper

  helper_method :depp_controller?
  def depp_controller?
    false
  end

  helper_method :head_title_sufix
  def head_title_sufix
    t(:registrar_head_title_sufix)
  end
end
