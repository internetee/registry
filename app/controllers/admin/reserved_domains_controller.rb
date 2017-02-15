class Admin::ReservedDomainsController < AdminController
  load_and_authorize_resource
  before_action :set_domain, only: [:edit, :update]

  def index

    params[:q] ||= {}
    domains = ReservedDomain.all.order(:name)
    @q = domains.search(params[:q])
    @domains = @q.result.page(params[:page])
    @domains = @domains.per(params[:results_per_page]) if params[:results_per_page].to_i > 0

  end

  def new
    @domain = ReservedDomain.new
  end

  def edit
  end

  def create
    @domain = ReservedDomain.new(reserved_domain_params)

    if @domain.save
      flash[:notice] = I18n.t('domain_added')
      redirect_to admin_reserved_domains_path
    else
      flash.now[:alert] = I18n.t('failed_to_add_domain')
      render 'new'
    end
  end

  def update
    @domain.attributes = reserved_domain_update_params

    if @domain.save
      flash[:notice] = t('.updated')
      redirect_to admin_reserved_domains_path
    else
      render :edit
    end
  end

  def delete
    if ReservedDomain.find(params[:id]).destroy
      flash[:notice] = I18n.t('domain_deleted')
      redirect_to admin_reserved_domains_path
    else
      flash.now[:alert] = I18n.t('failed_to_delete_domain')
      redirect_to admin_reserved_domains_path
    end
  end

  private

  def reserved_domain_params
    params.require(:reserved_domain).permit(:name, :password)
  end

  def reserved_domain_update_params
    params.require(:reserved_domain).permit(:password)
  end

  def set_domain
    @domain = ReservedDomain.find(params[:id])
  end
end
