module Admin
  class ReservedDomainsController < BaseController
    load_and_authorize_resource
    before_action :set_domain, only: [:edit, :update, :destroy]

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

      if dispute
        @domain.password = dispute.password
      end

      if @domain.save
        if !created_with_dispute_password
          flash[:notice] = t('.created')
        else
          flash[:notice] = t('.created_with_dispute_password_html')
        end

        redirect_to admin_reserved_domains_url
      else
        render :new
      end
    end

    def update
      raise t('admin.reserved_domains.reserved_domain.edit_prohibited') if dispute

      @domain.attributes = reserved_domain_update_params

      if @domain.save
        flash[:notice] = t('.updated')
        redirect_to admin_reserved_domains_url
      else
        render :edit
      end
    end

    def destroy
      if @domain.destroy
        flash[:notice] = t('.deleted')
      else
        flash.now[:alert] = t('.not_deleted')
      end

      redirect_to admin_reserved_domains_url
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

    def dispute
      @dispute ||= Dispute.find_by(domain_name: @domain.name)
    end

    def created_with_dispute_password
      dispute && reserved_domain_params[:password].present?
    end
  end
end
