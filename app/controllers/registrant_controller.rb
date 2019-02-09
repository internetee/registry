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
    current_registrant_user.present? ? current_registrant_user.id_role_username : 'anonymous'
  end

  def current_user_contacts
    current_registrant_user.contacts
  rescue CompanyRegister::NotAvailableError
    flash.now[:notice] = t('registrant.company_register_unavailable')
    current_registrant_user.direct_contacts
  end

  def current_user_domains
    current_registrant_user.domains
  rescue CompanyRegister::NotAvailableError
    flash.now[:notice] = t('registrant.company_register_unavailable')
    current_registrant_user.direct_domains
  end
end