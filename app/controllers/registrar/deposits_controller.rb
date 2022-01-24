class Registrar
  class DepositsController < BaseController
    authorize_resource class: false

    def new
      @deposit = Deposit.new
    end

    def create
      @deposit = Deposit.new(deposit_params.merge(registrar: current_registrar_user.registrar))
      @invoice = @deposit.issue_prepayment_invoice

      if @invoice
        flash[:notice] = t(:please_pay_the_following_invoice)
        send_invoice_data_to_billing_system
        redirect_to [:registrar, @invoice]
      else
        flash[:alert] = @deposit.errors.full_messages.join(', ')
        redirect_to new_registrar_deposit_path
      end
    end

    private

    def send_invoice_data_to_billing_system
      add_invoice_instance = EisBilling::AddDeposits.new(@invoice)
      result = add_invoice_instance.send_invoice
      link = JSON.parse(result.body)['everypay_link']

      @invoice.update(payment_link: link)
    end

    def deposit_params
      params.require(:deposit).permit(:amount, :description)
    end
  end
end
