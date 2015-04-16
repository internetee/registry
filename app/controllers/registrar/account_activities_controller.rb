class Registrar::AccountActivitiesController < RegistrarController
  load_and_authorize_resource

  def index
    account = current_user.registrar.cash_account
    @q = account.activities.includes(:invoice).search(params[:q])
    @q.sorts = 'id desc' if @q.sorts.empty?
    @account_activities = @q.result.page(params[:page])
  end
end
