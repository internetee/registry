class Admin::EppLogsController < AdminController
  load_and_authorize_resource class: ApiLog::EppLog
  before_action :set_default_dates, only: [:index]

  def index
    @q = ApiLog::EppLog.search(params[:q])
    @q.sorts = 'id desc' if @q.sorts.empty?
    @epp_logs = @q.result.page(params[:page])
  end

  def show
    @epp_log = ApiLog::EppLog.find(params[:id])
  end

  def set_default_dates
    params[:q] ||= {}

    if params[:q][:created_at_gteq].nil? && params[:q][:created_at_lteq].nil? && params[:clear_fields].nil?
      params[:q][:created_at_gteq] = Time.now.strftime("%Y-%m-%d")
    end

  end
end
