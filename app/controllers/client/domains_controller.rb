class Client::DomainsController < ClientController
  load_and_authorize_resource
  before_action :set_domain, only: [:show, :edit, :update, :destroy]
  before_action :verify_deletion, only: [:destroy]

  def index
    @q = Domain.search(params[:q]) if current_user.admin?
    @q = current_user.registrar.domains.search(params[:q]) unless current_user.admin?
    @domains = @q.result.page(params[:page])
  end

  def new
    owner_contact = Contact.find(params[:owner_contact_id]) if params[:owner_contact_id]
    @domain = Domain.new(owner_contact: owner_contact, registrar: current_user.registrar)
    params[:domain_owner_contact] = owner_contact

    build_associations
  end

  def create
    @domain = Domain.new(domain_params)
    @domain.registrar = current_user.registrar

    if @domain.save
      flash[:notice] = I18n.t('shared.domain_added')
      redirect_to [:client, @domain]
    else
      build_associations
      flash.now[:alert] = I18n.t('shared.failed_to_add_domain')
      render 'new'
    end
  end

  def edit
    build_associations
  end

  def update
    if @domain.update(domain_params)
      flash[:notice] = I18n.t('shared.domain_updated')
      redirect_to [:client, @domain]
    else
      build_associations
      flash[:alert] = I18n.t('shared.failed_to_update_domain')
      render 'edit'
    end
  end

  def destroy
    if @domain.destroy
      flash[:notice] = I18n.t('shared.domain_deleted')
      redirect_to client_domains_path
    else
      flash[:alert] = I18n.t('shared.failed_to_delete_domain')
      redirect_to [:client, @domain]
    end
  end

  private

  def domain_params
    params.require(:domain).permit(
      :name,
      :period,
      :period_unit,
      :owner_contact_id,
      :owner_contact_typeahead,
      nameservers_attributes: [:id, :hostname, :ipv4, :ipv6, :_destroy],
      domain_contacts_attributes: [:id, :contact_type, :contact_id, :value_typeahead, :_destroy],
      domain_statuses_attributes: [:id, :value, :description, :_destroy]
    )
  end

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
    redirect_to [:client, @domain]
  end
end
