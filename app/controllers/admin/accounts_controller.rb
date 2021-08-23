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
        @sum = params[:account][:balance].to_f - @account.balance
        action = Actions::AccountActivityCreate.new(@account,
                                                    @sum,
                                                    params[:description],
                                                    AccountActivity::UPDATE_CREDIT)

        unless action.call
          handle_errors(@account)
          render 'edit'
        end
        redirect_to admin_accounts_path, notice: t('.updated')
      else
        render 'edit'
      end
    end

    private

    def account_params
      params.require(:account).permit(:id, :currency, :balance)
    end
  end
end
