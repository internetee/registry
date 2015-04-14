class Admin::BankStatementsController < AdminController
  load_and_authorize_resource

  before_action :set_bank_statement, only: [:show, :download_import_file]

  def index
    @q = BankStatement.search(params[:q])
    @q.sorts  = 'id desc' if @q.sorts.empty?
    @bank_statements = @q.result.page(params[:page])
  end

  def show
    @q = @bank_statement.bank_transactions.search(params[:q])
    @bank_transactions = @q.result.page(params[:page])
  end

  def new
    @bank_statement = BankStatement.new
  end

  def create
    @bank_statement = BankStatement.new(bank_statement_params)

    if @bank_statement.import
      flash[:notice] = I18n.t('record_created')
      redirect_to [:admin, @bank_statement]
    else
      flash.now[:alert] = I18n.t('failed_to_create_record')
      render 'new'
    end
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
    params.require(:bank_statement).permit(:th6_file)
  end
end
