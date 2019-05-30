module Admin
  class BankStatementsController < BaseController
    load_and_authorize_resource

    before_action :set_bank_statement, only: %i[show download_import_file bind_invoices]

    def index
      @q = BankStatement.search(params[:q])
      @q.sorts = 'id desc' if @q.sorts.empty?
      @bank_statements = @q.result.page(params[:page])
    end

    def show
      @q = @bank_statement.bank_transactions.includes(:account_activity).search(params[:q])
      @q.sorts = 'account_activity_id desc' if @q.sorts.empty?
      @bank_transactions = @q.result.page(params[:page])
    end

    def new
      @bank_statement = BankStatement.new(
        bank_code: Setting.registry_bank_code,
        iban: Setting.registry_iban
      )
      @invoice = Invoice.find_by(id: params[:invoice_id])
      if @invoice
        @bank_transaction = @bank_statement.bank_transactions.build(
          description: @invoice.to_s,
          sum: @invoice.total,
          reference_no: @invoice.reference_no,
          paid_at: Time.zone.now.to_date,
          currency: 'EUR'
        )
      end
    end

    def create
      @bank_statement = BankStatement.new(bank_statement_params)

      if @bank_statement.save
        flash[:notice] = I18n.t('record_created')
        redirect_to [:admin, @bank_statement]
      else
        flash.now[:alert] = I18n.t('failed_to_create_record')
        render 'new'
      end
    end

    def import
      @bank_statement = BankStatement.new
    end

    def create_from_import
      @bank_statement = BankStatement.new(bank_statement_params)

      if @bank_statement.import
        flash[:notice] = I18n.t('record_created')
        redirect_to [:admin, @bank_statement]
      else
        flash.now[:alert] = I18n.t('failed_to_create_record')
        render 'new'
      end
    end

    def bind_invoices
      @bank_statement.bind_invoices

      flash[:notice] = t('invoices_were_fully_binded') if @bank_statement.fully_binded?
      flash[:warning] = t('invoices_were_partially_binded') if @bank_statement.partially_binded?
      flash[:alert] = t('no_invoices_were_binded') if @bank_statement.not_binded?

      redirect_to [:admin, @bank_statement]
    end

    def download_import_file
      filename = @bank_statement.import_file_path.split('/').last
      send_data File.open(@bank_statement.import_file_path, 'r').read, filename: filename
    end

    private

    def set_bank_statement
      @bank_statement = BankStatement.find(params[:id])
    end

    def bank_statement_params
      params.require(:bank_statement).permit(:th6_file, :bank_code, :iban, bank_transactions_attributes: %i[
                                               description sum currency reference_no paid_at
                                             ])
    end
  end
end
