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
    @q.sorts = 'id desc' if @q.sorts.empty?
    @b = AccountActivity.search(balance_params).result.where.not(id: @q.result.map(&:id))

    respond_to do |format|
      format.html { @account_activities = @q.result.page(params[:page]) }
      format.csv do
        send_data @q.result.to_csv, filename: "account_activities_#{Time.zone.now.to_formatted_s(:number)}.csv"
      end
    end

    params[:q][:created_at_lteq] = ca_cache
  end
end
