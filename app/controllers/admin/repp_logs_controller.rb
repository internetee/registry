module Admin
  class ReppLogsController < BaseController
    load_and_authorize_resource class: ApiLog::ReppLog
    before_action :set_default_dates, only: [:index]

    # rubocop:disable Metrics/MethodLength
    def index
      @q = ApiLog::ReppLog.ransack(PartialSearchFormatter.format(params[:q]))
      @q.sorts = 'id desc' if @q.sorts.empty?
      @result = @q.result
      @repp_logs = @result
      if params[:q][:created_at_gteq].present?
        @repp_logs = @repp_logs.where("extract(epoch from created_at) >= extract(epoch from ?::timestamp)",
                                      Time.parse(params[:q][:created_at_gteq]))
      end
      if params[:q][:created_at_lteq].present?
        @repp_logs = @repp_logs.where("extract(epoch from created_at) <= extract(epoch from ?::timestamp)",
                                      Time.parse(params[:q][:created_at_lteq]))
      end
      @repp_logs = @repp_logs.page(params[:page])
      @count = @q.result.count
      @repp_logs = @repp_logs.per(params[:results_per_page]) if paginate?

      render_by_format('admin/repp_logs/index', 'repp_logs')
    end
    # rubocop:enable Metrics/MethodLength

    def show
      @repp_log = ApiLog::ReppLog.find(params[:id])
    end

    def set_default_dates
      params[:q] ||= {}
      return unless default_dates?

      default_date = params[:created_after]
      default_date = 'today' unless %w[today tomorrow yesterday].include?(default_date)

      params[:q][:created_at_gteq] = Date.send(default_date).strftime("%Y-%m-%d")
    end

    private

    def default_dates?
      params[:q] ||= {}
      params[:q][:created_at_gteq].nil? && params[:q][:created_at_lteq].nil? && params[:created_after].present?
    end
  end
end
