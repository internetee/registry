module Admin
  class BankTransactionsController < BaseController
    load_and_authorize_resource

    def new
      @bank_statement = BankStatement.find(params[:bank_statement_id])
      @bank_transaction = BankTransaction.new(currency: 'EUR')
    end

    def create
      comma_support_for(:bank_transaction, :sum)
      @bank_transaction = BankTransaction.new(
        bank_transaction_params.merge(bank_statement_id: params[:bank_statement_id])
      )

      if @bank_transaction.save
        flash[:notice] = I18n.t('record_created')
        redirect_to [:admin, @bank_transaction]
      else
        flash.now[:alert] = I18n.t('failed_to_create_record')
        render 'new'
      end
    end

    def update
      comma_support_for(:bank_transaction, :sum)
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
      params.require(:bank_transaction).permit(
        :description, :sum, :reference_no, :document_no,
        :bank_reference, :iban, :buyer_bank_code, :buyer_iban,
        :buyer_name, :currency, :paid_at
      )
    end
  end
end
