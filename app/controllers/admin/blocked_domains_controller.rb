class Admin::BlockedDomainsController < AdminController
  load_and_authorize_resource

  def index

    params[:q] ||= {}
    domains = BlockedDomain.all
    @q = domains.search(params[:q])
    @domains = @q.result.page(params[:page])
    @domains = @domains.per(params[:results_per_page]) if params[:results_per_page].to_i > 0

  end

  def new

    @domain = BlockedDomain.new

  end

  def create

    abort

  end

  def delete

    if BlockedDomain.find(params[:id]).destroy
      flash[:notice] = I18n.t('domain_deleted')
      redirect_to admin_blocked_domains_path
    else
      flash.now[:alert] = I18n.t('failed_to_delete_domain')
      redirect_to admin_blocked_domains_path
    end
  end


  def blocked_params
    params.require(:blocked_domain).permit(:name)
  end

  private

  def set_domain
    @domain = BlockedDomain.find(params[:id])
  end
end