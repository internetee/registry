module Admin
  class ReppLogsController < BaseController
    load_and_authorize_resource class: ApiLog::ReppLog
    before_action :set_default_dates, only: [:index]

    def index
      @q = ApiLog::ReppLog.search(params[:q])
      @q.sorts = 'id desc' if @q.sorts.empty?

      @repp_logs = @q.result
      @repp_logs = @repp_logs.where("extract(epoch from created_at) >= extract(epoch from ?::timestamp)", Time.parse(params[:q][:created_at_gteq])) if params[:q][:created_at_gteq].present?
      @repp_logs = @repp_logs.where("extract(epoch from created_at) <= extract(epoch from ?::timestamp)", Time.parse(params[:q][:created_at_lteq])) if params[:q][:created_at_lteq].present?
      @repp_logs = @repp_logs.page(params[:page])
      @count = @q.result.count
      @repp_logs = @repp_logs.per(params[:results_per_page]) if paginate?

      respond_to do |format|
        format.html do
          render 'admin/repp_logs/index'
        end
        format.csv do
          raw_csv = @q.result.to_csv
          send_data raw_csv,
                    filename: "repp_logs_#{Time.zone.now.to_formatted_s(:number)}.csv",
                    type: "#{Mime[:csv]}; charset=utf-8"
        end
      end
    end

    def show
      @repp_log = ApiLog::ReppLog.find(params[:id])
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
