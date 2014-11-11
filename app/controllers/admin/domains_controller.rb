class Admin::DomainsController < AdminController
  before_action :set_domain, only: [:show, :edit, :update, :zonefile]

  def index
    @q = Domain.includes(:registrar, :owner_contact).search(params[:q])
    @domains = @q.result.page(params[:page])
  end

  def show
    @domain.all_dependencies_valid?
  end

  def edit
    build_associations
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

  def zonefile
    @zonefile = @domain.generate_zonefile
    # send_data @zonefile, filename: 'bla.txt'
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

  def build_associations
    @domain.domain_statuses.build if @domain.domain_statuses.empty?
    @server_statuses = @domain.domain_statuses.select(&:server_status?)
    @server_statuses << @domain.domain_statuses.build if @server_statuses.empty?
  end

  def add_prefix_to_statuses
    domain_params[:domain_statuses_attributes].each do |_k, hash|
      hash[:value] = hash[:value].prepend('server') if hash[:value].present?
    end
  end
end
