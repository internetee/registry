module Admin
  class BlockedDomainsController < BaseController
    load_and_authorize_resource

    def index
      params[:q] ||= {}
      domains = BlockedDomain.all.order(:name)
      @q = domains.search(params[:q])
      @domains = @q.result.page(params[:page])
      @domains = @domains.per(params[:results_per_page]) if params[:results_per_page].to_i.positive?

      respond_to do |format|
        format.html do
          render 'admin/blocked_domains/index'
        end
        format.csv do
          raw_csv = @q.result.to_csv
          send_data raw_csv,
                    filename: "blocked_domains_#{Time.zone.now.to_formatted_s(:number)}.csv",
                    type: "#{Mime[:csv]}; charset=utf-8"
        end
      end
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
        redirect_to admin_blocked_domains_path
      else
        flash.now[:alert] = I18n.t('failed_to_delete_domain')
        redirect_to admin_blocked_domains_path
      end
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
