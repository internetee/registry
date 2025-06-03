module Admin
  class EppLogsController < BaseController
    load_and_authorize_resource class: ApiLog::EppLog
    before_action :set_default_dates, only: [:index]

    # rubocop:disable Metrics/MethodLength
    def index
      @q = ApiLog::EppLog.ransack(PartialSearchFormatter.format(params[:q]))
      @q.sorts = 'id desc' if @q.sorts.empty?
      @result = @q.result

      @epp_logs = @result
      if params[:q][:created_at_gteq].present?
        @epp_logs = @epp_logs.where('extract(epoch from created_at) >= extract(epoch from ?::timestamp)',
                                    Time.parse(params[:q][:created_at_gteq]))
      end
      if params[:q][:created_at_lteq].present?
        @epp_logs = @epp_logs.where('extract(epoch from created_at) <= extract(epoch from ?::timestamp)',
                                    Time.parse(params[:q][:created_at_lteq]))
      end
      @epp_logs = @epp_logs.page(params[:page])

      render_by_format('admin/epp_logs/index', 'epp_logs')
    end
    # rubocop:enable Metrics/MethodLength

    def show
      @epp_log = ApiLog::EppLog.find(params[:id])
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
      date.strftime('%Y-%m-%d')
    end
  end
end
