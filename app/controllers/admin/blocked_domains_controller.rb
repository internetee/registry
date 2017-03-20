module Admin
  class BlockedDomainsController < BaseController
    load_and_authorize_resource

    def index
      params[:q] ||= {}
      domains = BlockedDomain.all.order(:name)
      @q = domains.search(params[:q])
      @domains = @q.result.page(params[:page])
      @domains = @domains.per(params[:results_per_page]) if params[:results_per_page].to_i > 0
    end

    def new
      @domain = BlockedDomain.new
    end

    def create
      @domain = BlockedDomain.new(blocked_domain_params)

      if @domain.save
        flash[:notice] = t('.created')
        redirect_to admin_blocked_domains_url
      else
        render 'new'
      end
    end

    def destroy
      @domain = BlockedDomain.find(params[:id])

      if @domain.destroy
        flash[:notice] = t('.deleted')
      else
        flash.now[:alert] = t('.not_deleted')
      end

      redirect_to admin_blocked_domains_url
    end

    private

    def blocked_domain_params
      params.require(:blocked_domain).permit(:name)
    end
  end
end
