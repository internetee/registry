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

      @q = AccountActivity.includes(:invoice, account: :registrar).ransack(params[:q])
      @b = AccountActivity.ransack(balance_params)
      @q.sorts = 'id desc' if @q.sorts.empty?

      @account_activities = @q.result.page(params[:page]).per(params[:results_per_page])
      @count = @q.result.count

      @sum = if params[:page] && params[:page].to_i > 1
               @q.result.limit(@account_activities.offset_value).sum(:sum) +
                 @b.result.where("account_activities.id NOT IN (#{@q.result.select(:id).to_sql})").sum(:sum)
             else
               @b.result.where("account_activities.id NOT IN (#{@q.result.select(:id).to_sql})").sum(:sum)
             end

      respond_to do |format|
        format.html
        format.csv do
          raw_csv = CsvGenerator.generate_csv(@q.result)
          send_data raw_csv, filename: "account_activities_#{Time.zone.now.to_formatted_s(:number)}.csv"
        end
      end

      params[:q][:created_at_lteq] = ca_cache
    end

    def set_default_dates
      params[:q] ||= {}
      return unless default_dates?

      params[:q][:created_at_gteq] = format_date(parse_default_date)
    end

    private

    def default_dates?
      params[:q][:created_at_gteq].nil? && 
      params[:q][:created_at_lteq].nil? && 
      params[:created_after].present?
    end

    def parse_default_date
      case params[:created_after]
      when 'today'     then Date.today
      when 'tomorrow'  then Date.tomorrow
      when 'yesterday' then Date.yesterday
      else Date.today
      end
    end

    def format_date(date)
      date.strftime("%Y-%m-%d")
    end
  end
end
