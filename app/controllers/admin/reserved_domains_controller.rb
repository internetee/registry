module Admin
  class ReservedDomainsController < BaseController
    load_and_authorize_resource
    before_action :set_domain, only: [:edit, :update]

    def index
      params[:q] ||= {}
      domains = ReservedDomain.all.order(:name)
      @q = domains.ransack(PartialSearchFormatter.format(params[:q]))
      @result = @q.result
      @domains = @result.page(params[:page])
      @domains = @domains.per(params[:results_per_page]) if params[:results_per_page].to_i.positive?

      render_by_format('admin/reserved_domains/index', 'reserved_domains')
    end

    def new
      @domain = ReservedDomain.new
    end

    def edit; end

    def create
      @domain = ReservedDomain.new(reserved_domain_params)

      ReservedDomain::Audit.set(source: 'admin', reason: 'admin_created',
                                reason_note: nil, registrar_id: nil) do
        if @domain.save
          flash[:notice] = I18n.t('domain_added')
          redirect_to admin_reserved_domains_path
        else
          flash.now[:alert] = I18n.t('failed_to_add_domain')
          render 'new'
        end
      end
    end

    def update
      if params[:reason_note].blank?
        @domain.assign_attributes(reserved_domain_params)
        flash.now[:alert] = I18n.t('reason_note_required')
        return render 'edit'
      end

      ReservedDomain::Audit.set(source: 'admin', reason: 'admin_updated',
                                reason_note: params[:reason_note], registrar_id: nil) do
        if @domain.update(reserved_domain_params)
          flash[:notice] = I18n.t('domain_updated')
        else
          flash.now[:alert] = I18n.t('failed_to_update_domain')
        end
      end

      render 'edit'
    end

    def delete
      if params[:reason_note].blank?
        flash[:alert] = I18n.t('reason_note_required')
        return redirect_to admin_reserved_domains_path
      end

      ReservedDomain::Audit.set(source: 'admin', reason: 'admin_deleted',
                                reason_note: params[:reason_note], registrar_id: nil) do
        if ReservedDomain.find(params[:id]).destroy
          flash[:notice] = I18n.t('domain_deleted')
        else
          flash.now[:alert] = I18n.t('failed_to_delete_domain')
        end
      end

      redirect_to admin_reserved_domains_path
    end

    def release_to_auction
      redirect_to admin_reserved_domains_path and return if params[:reserved_elements].nil?

      reserved_domains_ids = params[:reserved_elements][:domain_ids]
      reserved_domains = ReservedDomain.where(id: reserved_domains_ids)

      ReservedDomain::Audit.set(source: 'admin', reason: 'released_to_auction',
                                reason_note: nil, registrar_id: nil) do
        reserved_domains.each do |domain|
          Auction.create!(domain: domain.name, status: Auction.statuses[:started], platform: 'manual')
          domain.destroy!
        end
      end

      redirect_to admin_auctions_path
    end

    private

    def reserved_checked_elements
      # params.require(:reserved_elements).permit(:name, :password)
    end

    def reserved_domain_params
      params.require(:reserved_domain).permit(:name, :password, :expire_at)
    end

    def set_domain
      @domain = ReservedDomain.find(params[:id])
    end
  end
end
