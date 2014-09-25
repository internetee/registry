module Shared::CommonDomain
  extend ActiveSupport::Concern

  included do
    load_and_authorize_resource
    before_action :set_domain, only: [:show, :edit, :update, :destroy]
    before_action :verify_deletion, only: [:destroy]
  end

  def edit
    build_associations
  end

  private

  def set_domain
    @domain = Domain.find(params[:id])
  end

  def build_associations
    @domain.nameservers.build if @domain.nameservers.empty?
    @domain.domain_contacts.build if @domain.domain_contacts.empty?
    @domain.domain_statuses.build if @domain.domain_statuses.empty?
  end

  def verify_deletion
    return if @domain.can_be_deleted?
    flash[:alert] = I18n.t('shared.domain_status_prohibits_deleting')
    redirect_to [:admin, @domain]
  end
end
