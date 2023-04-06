module Admin
  class BlockedDomainsController < BaseController
    load_and_authorize_resource

    def index
      params[:q] ||= {}
      domains = BlockedDomain.all.order(:name)
      @q = domains.ransack(PartialSearchFormatter.format(params[:q]))
      @result = @q.result
      @domains = @result.page(params[:page])
      @domains = @domains.per(params[:results_per_page]) if params[:results_per_page].to_i.positive?

      render_by_format('admin/blocked_domains/index', 'blocked_domains')
    end

    def new
      @domain = BlockedDomain.new
    end

    def create
      @domain = BlockedDomain.new(blocked_domain_params)

      if @domain.save
        flash[:notice] = I18n.t('domain_added')
        redirect_to admin_blocked_domains_path
      else
        flash.now[:alert] = I18n.t('failed_to_add_domain')
        render 'new'
      end
    end

    def delete
      if BlockedDomain.find(params[:id]).destroy
        flash[:notice] = I18n.t('domain_deleted')
      else
        flash.now[:alert] = I18n.t('failed_to_delete_domain')
      end

      redirect_to admin_blocked_domains_path
    end

    def blocked_domain_params
      params.require(:blocked_domain).permit(:name)
    end

    private

    def set_domain
      @domain = BlockedDomain.find(params[:id])
    end
  end
end
