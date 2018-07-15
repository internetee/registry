class RegistrantController < ApplicationController
  before_action :authenticate_registrant_user!
  layout 'registrant/application'

  include Registrant::ApplicationHelper

  helper_method :head_title_sufix

  def head_title_sufix
    t(:registrant_head_title_sufix)
  end

  private

  def current_ability
    @current_ability ||= Ability.new(current_registrant_user, request.remote_ip)
  end

  def user_for_paper_trail
    current_registrant_user.present? ? current_registrant_user.id_role_username : 'guest'
  end
end