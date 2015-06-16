class Admin::DomainsController < AdminController
  load_and_authorize_resource
  before_action :set_domain, only: [:show, :edit, :update, :zonefile]

  def index
    @q = Domain.includes(:registrar, :registrant).search(params[:q])
    @domains = @q.result.page(params[:page])
  end

  def show
    @domain.valid?
  end

  def edit
    build_associations
  end

  def update
    dp = add_prefix_to_statuses

    if @domain.update(dp)
      flash[:notice] = I18n.t('domain_updated')
      redirect_to [:admin, @domain]
    else
      @domain.domain_statuses.build if @domain.domain_statuses.empty?
      flash.now[:alert] = I18n.t('failed_to_update_domain')
      render 'edit'
    end
  end

  def set_force_delete
    if @domain.set_force_delete
      flash[:notice] = I18n.t('domain_updated')
    else
      flash.now[:alert] = I18n.t('failed_to_update_domain')
    end
    redirect_to [:admin, @domain]
  end

  def unset_force_delete
    if @domain.unset_force_delete
      flash[:notice] = I18n.t('domain_updated')
    else
      flash.now[:alert] = I18n.t('failed_to_update_domain')
    end
    redirect_to [:admin, @domain]
  end

  private

  def set_domain
    @domain = Domain.find(params[:id])
  end

  def domain_params
    if params[:domain]
      params.require(:domain).permit({ statuses: [] })
    else
      {statuses: []}
    end
  end

  def build_associations
    @domain.domain_statuses.build if @domain.domain_statuses.empty?
    @server_statuses = @domain.statuses.select { |x| DomainStatus::SERVER_STATUSES.include?(x) }
    @server_statuses = [nil] if @server_statuses.empty?
  end

  def add_prefix_to_statuses
    dp = domain_params
    dp[:statuses] = domain_params[:statuses].map { |x| x.prepend('server') if x.present? }
    dp[:statuses].reject! { |x| x.blank? }
    dp
  end
end

