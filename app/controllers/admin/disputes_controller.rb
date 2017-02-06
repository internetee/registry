module Admin
  class DisputesController < BaseController
    load_and_authorize_resource

    def index
      @disputes = @disputes.includes(:domain).latest_on_top
    end

    def new
      @dispute = Dispute.new
    end

    def create
      @dispute = Dispute.new(dispute_params)
      created = @dispute.save

      if created
        flash[:notice] = t('.created')
        redirect_to admin_disputes_path
      else
        render :new
      end
    end

    def edit
    end

    def update
      updated = @dispute.update(dispute_params)

      if updated
        flash[:notice] = t('.updated')
        redirect_to admin_disputes_path
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
      params.require(:dispute).permit(:domain_name, :expire_date, :password, :comment)
    end
  end
end
