module Admin
  class DisputesController < BaseController
    load_and_authorize_resource

    def index
      @search = OpenStruct.new(search_params)
      @disputes = @disputes.by_domain_name(search_params[:domain_name]).by_expire_date(expire_date).latest_on_top
    end

    def show
    end

    def new
      @dispute = Dispute.new
    end

    def create
      @dispute = Dispute.new(dispute_params)
      created = DisputeCreation.new(dispute: @dispute).create

      if created
        flash[:notice] = t('.created')
        redirect_to admin_dispute_url(@dispute)
      else
        render :new
      end
    end

    def edit
    end

    def update
      @dispute.attributes = dispute_params
      updated = DisputeUpdate.new(dispute: @dispute).update

      if updated
        flash[:notice] = t('.updated')
        redirect_to admin_dispute_url(@dispute)
      else
        render :edit
      end
    end

    def destroy
      if @dispute.close
        flash[:notice] = t('.closed')
      else
        flash[:alert] = t('.not_closed')
      end

      redirect_to admin_disputes_url
    end

    private

    def dispute_params
      allowed_params = %i(
        domain_name
        expire_date
        password
        comment
      )

      params.require(:dispute).permit(allowed_params)
    end

    def search_params
      allowed_params = %i(
        domain_name
        expire_date_start
        expire_date_end
      )
      params.fetch(:search, {}).permit(allowed_params)
    end

    def expire_date
      return if search_params[:expire_date_start].blank? || search_params[:expire_date_end].blank?
      Date.parse(search_params[:expire_date_start])..Date.parse(search_params[:expire_date_end])
    end
  end
end
