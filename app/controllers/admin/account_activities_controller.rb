module Admin
  class AccountActivitiesController < BaseController
    load_and_authorize_resource
    before_action :set_default_dates, only: [:index]

    def index
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

      # can do here inline SQL as it's our
      if params[:page] && params[:page].to_i > 1
        @sum = @q.result.reorder(sort).limit(@account_activities.offset_value).sum(:sum) + @b.result.where("account_activities.id NOT IN (#{@q.result.select(:id).to_sql})").sum(:sum)
      else
        @sum = @b.result.where("account_activities.id NOT IN (#{@q.result.select(:id).to_sql})").sum(:sum)
      end

      respond_to do |format|
        format.html
        format.csv do
          send_data @q.result.to_csv, filename: "account_activities_#{Time.zone.now.to_formatted_s(:number)}.csv"
        end
      end

      params[:q][:created_at_lteq] = ca_cache
    end

    def set_default_dates
      params[:q] ||= {}

      if params[:q][:created_at_gteq].nil? && params[:q][:created_at_lteq].nil? && params[:created_after].present?

        default_date = params[:created_after]

        if !['today', 'tomorrow', 'yesterday'].include?(default_date)
          default_date = 'today'
        end

        params[:q][:created_at_gteq] = Date.send(default_date).strftime("%Y-%m-%d")
      end

    end
  end
end
