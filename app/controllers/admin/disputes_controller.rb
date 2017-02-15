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
      @dispute.generate_password unless password_provided

      if @dispute.valid?(:admin)
        @dispute.transaction do
          @dispute.save!
          prohibit_registrant_change!
          sync_reserved_domain!
        end

        flash[:notice] = t('.created')
        redirect_to admin_dispute_path(@dispute)
      else
        render :new
      end
    end

    def edit
    end

    def update
      @dispute.attributes = dispute_params
      @dispute.generate_password unless password_provided

      if @dispute.valid?(:admin)
        @dispute.transaction do
          @dispute.save!
          sync_reserved_domain!
        end

        flash[:notice] = t('.updated')
        redirect_to admin_dispute_path(@dispute)
      else
        render :edit
      end
    end

    def destroy
      if @dispute.destroy
        flash[:notice] = t('.deleted')
      end

      redirect_to admin_disputes_path
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

    def sync_reserved_domain!
      reserved_domain = ReservedDomain.find_by(name: @dispute.domain_name)

      return unless reserved_domain

      reserved_domain.password = @dispute.password
      reserved_domain.save!
    end

    def password_provided
      dispute_params[:password].present?
    end

    def prohibit_registrant_change!
      domain = Domain.find_by(name: @dispute.domain_name)

      return unless domain

      domain.prohibit_registrant_change
      domain.save!
    end
  end
end
