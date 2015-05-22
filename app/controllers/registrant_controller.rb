class RegistrantController < ApplicationController
  before_action :authenticate_user!
  layout 'registrant/application'

  include Registrant::ApplicationHelper

  helper_method :head_title_sufix
  def head_title_sufix
    t(:registrant_head_title_sufix)
  end
end
