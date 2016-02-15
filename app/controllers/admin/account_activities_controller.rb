class Admin::AccountActivitiesController < AdminController
  load_and_authorize_resource

  def index # rubocop: disable Metrics/AbcSize
    params[:q] ||= {}

    ca_cache = params[:q][:created_at_lteq]
    begin
      end_time = params[:q][:created_at_lteq].try(:to_date)
      params[:q][:created_at_lteq] = end_time.try(:end_of_day)
    rescue
      logger.warn('Invalid date')
    end

    balance_params = params[:q].deep_dup

    if balance_params[:created_at_gteq]
      balance_params.delete('created_at_gteq')
    end

    @q = AccountActivity.includes(:invoice, account: :registrar).search(params[:q])
    @b = AccountActivity.search(balance_params)
    @q.sorts = 'id desc' if @q.sorts.empty?

    @account_activities = @q.result.page(params[:page]).per(params[:results_per_page])
    sort = @account_activities.orders.map(&:to_sql).join(",")

    if params[:page] && params[:page].to_i > 1
      @sum = @q.result.reorder(sort).limit(@account_activities.offset_value) + @b.result.where.not(id: @q.result.map(&:id))
    else
      @sum = @b.result.where.not(id: @q.result.map(&:id))
    end

    respond_to do |format|
      format.html
      format.csv do
        send_data @q.result.to_csv, filename: "account_activities_#{Time.zone.now.to_formatted_s(:number)}.csv"
      end
    end

    params[:q][:created_at_lteq] = ca_cache
  end
end
