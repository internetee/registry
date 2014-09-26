class Admin::DomainsController < AdminController
  before_action :set_domain, only: [:show, :edit, :update]

  def index
    @q = Domain.search(params[:q])
    @domains = @q.result.page(params[:page])
  end

  def show
    @domain.all_dependencies_valid?
  end

  def edit
    @domain.domain_statuses.build if @domain.domain_statuses.empty?
  end

  def update
    add_prefix_to_statuses

    if @domain.update(domain_params)
      flash[:notice] = I18n.t('shared.domain_updated')
      redirect_to [:admin, @domain]
    else
      @domain.domain_statuses.build if @domain.domain_statuses.empty?
      flash.now[:alert] = I18n.t('shared.failed_to_update_domain')
      render 'edit'
    end
  end

  private

  def set_domain
    @domain = Domain.find(params[:id])
  end

  def domain_params
    params.require(:domain).permit(
      domain_statuses_attributes: [:id, :value, :description, :_destroy]
    )
  end

  def add_prefix_to_statuses
    domain_params[:domain_statuses_attributes].each do |_k, hash|
      hash[:value] = hash[:value].prepend('server')
    end
  end
end
