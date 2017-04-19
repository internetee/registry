class Registrar
  class DepositsController < BaseController
    authorize_resource class: false

    def new
      @deposit = Deposit.new
    end

    def create
      @deposit = Deposit.new(deposit_params.merge(registrar: current_user.registrar))
      @invoice = @deposit.issue_prepayment_invoice

      if @invoice && @invoice.persisted?
        flash[:notice] = t(:please_pay_the_following_invoice)
        redirect_to [:registrar, @invoice]
      else
        flash.now[:alert] = t(:failed_to_create_record)
        render 'new'
      end
    end

    private

    def deposit_params
      params.require(:deposit).permit(:amount, :description)
    end
  end
end
