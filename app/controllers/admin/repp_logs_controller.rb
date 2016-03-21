class Admin::ReppLogsController < AdminController
  load_and_authorize_resource class: ApiLog::ReppLog
  before_action :set_default_dates, only: [:index]

  def index
    @q = ApiLog::ReppLog.search(params[:q])
    @q.sorts = 'id desc' if @q.sorts.empty?
    @repp_logs = @q.result.page(params[:page])
  end

  def show
    @repp_log = ApiLog::ReppLog.find(params[:id])
  end

  def set_default_dates
    params[:q] ||= {}

    if params[:q][:created_at_gteq].nil? && params[:q][:created_at_lteq].nil?
      params[:q][:created_at_gteq] = Time.now.strftime("%Y-%m-%d")
    end

  end
end
