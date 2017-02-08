module Admin
  class DisputesController < BaseController
    load_and_authorize_resource

    def index
      @disputes = @disputes.includes(:domain).latest_on_top
    end

    def show
    end

    def new
      @dispute = Dispute.new
    end

    def create
      @dispute = Dispute.new(dispute_params)
      @dispute.generate_password if password_not_provided

      created = @dispute.save

      if created
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
      @dispute.generate_password if password_not_provided
      updated = @dispute.save

      if updated
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
      params.require(:dispute).permit(:domain_name, :expire_date, :password, :comment)
    end

    def password_not_provided
      dispute_params[:password].blank?
    end
  end
end
