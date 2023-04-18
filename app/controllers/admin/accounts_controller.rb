module Admin
  class AccountsController < BaseController
    load_and_authorize_resource

    def index
      @q = Account.includes(:registrar).ransack(params[:q])
      @result = @q.result
      @accounts = @result.page(params[:page])
      @accounts = @accounts.per(params[:results_per_page]) if paginate?

      render_by_format('admin/accounts/index', 'accounts')
    end

    def show; end

    def edit; end

    def update
      action = Actions::AccountActivityCreate.new(@account,
                                                  params[:account][:balance],
                                                  params[:description],
                                                  AccountActivity::UPDATE_CREDIT)
      if action.call
        redirect_to admin_accounts_path, notice: t('.updated')
      else
        flash[:alert] = t('invalid_balance')
        render 'edit'
      end
    end
  end
end
