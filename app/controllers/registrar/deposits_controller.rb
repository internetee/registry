class Registrar
  class DepositsController < BaseController
    authorize_resource class: false

    def new
      @deposit = Deposit.new
    end

    def create
      @deposit = Deposit.new(deposit_params.merge(registrar: current_user.registrar))
      @invoice = @deposit.issue_prepayment_invoice

      if @invoice
        flash[:notice] = t(:please_pay_the_following_invoice)
        redirect_to [:registrar, @invoice]
      else
        flash[:alert] = @deposit.errors.full_messages.join(', ')
        redirect_to new_registrar_deposit_path
      end
    end

    private

    def deposit_params
      params.require(:deposit).permit(:amount, :description)
    end
  end
end
