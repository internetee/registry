class Registrar::AccountActivitiesController < RegistrarController
  load_and_authorize_resource

  def index
    params[:q] ||= {}
    account = current_user.registrar.cash_account

    ca_cache = params[:q][:created_at_lteq]
    end_time = params[:q][:created_at_lteq].try(:to_date)
    params[:q][:created_at_lteq] = end_time.try(:end_of_day)

    @q = account.activities.includes(:invoice).search(params[:q])
    @q.sorts = 'id desc' if @q.sorts.empty?
    @account_activities = @q.result.page(params[:page])

    params[:q][:created_at_lteq] = ca_cache
  end
end
