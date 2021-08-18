module Admin
  class AccountsController < BaseController
    load_and_authorize_resource

    def index
      @q = Account.includes(:registrar).search(params[:q])
      @accounts = @q.result.page(params[:page])
      @accounts = @accounts.per(params[:results_per_page]) if params[:results_per_page].to_i.positive?

      render_by_format('admin/accounts/index', 'accounts')
    end

    def show; end

    def edit; end

    def update
      if @account.valid?
        @sum = params[:account][:balance].to_f - @account.balance
        redirect_to admin_accounts_path, notice: t('.updated') if create_activity
      else
        render 'edit'
      end
    end

    private

    def create_activity
      activity = AccountActivity.new(account: @account,
                                     sum: @sum,
                                     currency: @account.currency,
                                     description: params[:description],
                                     activity_type: AccountActivity::ADD_CREDIT)

      if activity.save
        true
      else
        false
      end
    end

    def account_params
      params.require(:account).permit(:id, :currency, :balance)
    end
  end
end
