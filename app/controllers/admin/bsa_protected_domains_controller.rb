module Admin
  class BsaProtectedDomainsController < BaseController
    load_and_authorize_resource
    before_action :set_domain, only: %i[edit update]

    def index
      params[:q] ||= {}
      domains = BsaProtectedDomain.all.order(:domain_name)
      @q = domains.ransack(PartialSearchFormatter.format(params[:q]))
      @result = @q.result
      @domains = @result.page(params[:page])
      @domains = @domains.per(params[:results_per_page]) if params[:results_per_page].to_i.positive?
    end

    def new
      @domain = BsaProtectedDomain.new
    end

    def edit; end

    def create
      @domain = BsaProtectedDomain.new(bsa_protected_domain_params)

      if @domain.save
        flash[:notice] = I18n.t('domain_added')
        redirect_to admin_bsa_protected_domains_path
      else
        flash.now[:alert] = I18n.t('failed_to_add_domain')
        render 'new'
      end
    end

    def update
      if @domain.update(bsa_protected_domain_params)
        flash[:notice] = I18n.t('domain_updated')
      else
        flash.now[:alert] = I18n.t('failed_to_update_domain')
      end

      render 'edit'
    end

    def delete
      if BsaProtectedDomain.find(params[:id]).destroy
        flash[:notice] = I18n.t('domain_deleted')
      else
        flash.now[:alert] = I18n.t('failed_to_delete_domain')
      end

      redirect_to admin_bsa_protected_domains_path
    end

    def release_to_auction
      redirect_to admin_bsa_protected_domains_path and return if params[:bsa_protected_domains].nil?

      bsa_protected_domains_ids = params[:bsa_protected_domains][:domain_ids]
      bsa_protected_domains_domains = BsaProtectedDomain.where(id: bsa_protected_domains_ids)

      bsa_protected_domains_domains.each do |domain|
        Auction.create!(domain: domain.name, status: Auction.statuses[:started], platform: 'manual')
        domain.destroy!
      end

      redirect_to admin_auctions_path
    end

    private

    def bsa_protected_domain_params
      params.require(:bsa_protected_domain).permit(:domain_name, :registration_code,
                                                   :order_id, :suborder_id, :create_date, :state).tap do |whitelisted|
        whitelisted[:state] = whitelisted[:state].to_i if whitelisted[:state].is_a?(String)
      end
    end

    def set_domain
      @domain = BsaProtectedDomain.find(params[:id])
    end
  end
end
