class Client::DomainsController < ClientController
  include Shared::CommonDomain

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

  private

  def domain_params
    params.require(:domain).permit(
      :name,
      :period,
      :period_unit,
      :owner_contact_id,
      :owner_contact_typeahead,
      :registrar_typeahead,
      nameservers_attributes: [:id, :hostname, :ipv4, :ipv6, :_destroy],
      domain_contacts_attributes: [:id, :contact_type, :contact_id, :value_typeahead, :_destroy],
      domain_statuses_attributes: [:id, :value, :description, :_destroy]
    )
  end
end
