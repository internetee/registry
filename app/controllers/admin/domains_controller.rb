class Admin::DomainsController < ApplicationController
  before_action :set_domain, only: [:show, :edit, :update, :destroy]
  before_action :verify_deletion, only: [:destroy]

  def new
    owner_contact = Contact.find(params[:owner_contact_id]) if params[:owner_contact_id]
    @domain = Domain.new(owner_contact: owner_contact)
    params[:domain_owner_contact] = owner_contact

    build_associations
  end

  def create
    @domain = Domain.new(domain_params)

    if @domain.save
      flash[:notice] = I18n.t('shared.domain_added')
      redirect_to [:admin, @domain]
    else
      build_associations
      flash.now[:alert] = I18n.t('shared.failed_to_add_domain')
      render 'new'
    end
  end

  def index
    @q = Domain.search(params[:q])
    @domains = @q.result.page(params[:page])
  end

  def show
    @domain.all_dependencies_valid?
  end

  def edit
    build_associations
  end

  def update
    if @domain.update(domain_params)
      flash[:notice] = I18n.t('shared.domain_updated')
      redirect_to [:admin, @domain]
    else
      build_associations
      flash[:alert] = I18n.t('shared.failed_to_update_domain')
      render 'edit'
    end
  end

  def destroy
    if @domain.destroy
      flash[:notice] = I18n.t('shared.domain_deleted')
      redirect_to admin_domains_path
    else
      flash[:alert] = I18n.t('shared.failed_to_delete_domain')
      redirect_to [:admin, @domain]
    end
  end

  private

  def set_domain
    @domain = Domain.find(params[:id])
  end

  def domain_params
    params.require(:domain).permit(
      :name,
      :period,
      :period_unit,
      :registrar_id,
      :owner_contact_id,
      :owner_contact_typeahead,
      :registrar_typeahead,
      nameservers_attributes: [:id, :hostname, :ipv4, :ipv6, :_destroy],
      domain_contacts_attributes: [:id, :contact_type, :contact_id, :value_typeahead, :_destroy],
      domain_statuses_attributes: [:id, :value, :description, :_destroy]
    )
  end

  def build_associations
    @domain.nameservers.build if @domain.nameservers.empty?
    @domain.domain_contacts.build if @domain.domain_contacts.empty?
    @domain.domain_statuses.build if @domain.domain_contacts.empty?
  end

  def verify_deletion
    return if @domain.can_be_deleted?
    flash[:alert] = I18n.t('shared.domain_status_prohibits_deleting')
    redirect_to [:admin, @domain]
  end
end

