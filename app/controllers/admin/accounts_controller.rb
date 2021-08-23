module Admin
  class AccountsController < BaseController
    load_and_authorize_resource

    def index
      @q = Account.includes(:registrar).search(params[:q])
      @accounts = @q.result.page(params[:page])
      @accounts = @accounts.per(params[:results_per_page]) if paginate?

      render_by_format('admin/accounts/index', 'accounts')
    end

    def show; end

    def edit; end

    def update
      if @account.valid?
        action = Actions::AccountActivityCreate.new(@account,
                                                    params[:account][:balance],
                                                    params[:description],
                                                    AccountActivity::UPDATE_CREDIT)
        redirect_to admin_accounts_path, notice: t('.updated') && return if action.call
      end

      flash[:alert] = t('invalid_balance')
      render 'edit'
    end

    private

    def account_params
      params.require(:account).permit(:id, :currency, :balance)
    end
  end
end
