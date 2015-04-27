class Admin::BankTransactionsController < AdminController
  load_and_authorize_resource

  def update
    if @bank_transaction.update(bank_transaction_params)
      flash[:notice] = I18n.t('record_updated')
      redirect_to [:admin, @bank_transaction]
    else
      flash.now[:alert] = I18n.t('failed_to_update_record')
      render 'edit'
    end
  end

  def bind
    if @bank_transaction.bind_invoice(params[:invoice_no])
      flash[:notice] = I18n.t('record_created')
      redirect_to [:admin, @bank_transaction]
    else
      flash.now[:alert] = I18n.t('failed_to_create_record')
      render 'show'
    end
  end

  private

  def bank_transaction_params
    params.require(:bank_transaction).permit(:description, :sum, :reference_no)
  end
end
