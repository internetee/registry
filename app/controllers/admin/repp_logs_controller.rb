class Admin::ReppLogsController < ApplicationController
  load_and_authorize_resource class: ApiLog::ReppLog

  def index
    @q = ApiLog::ReppLog.search(params[:q])
    @q.sorts = 'id desc' if @q.sorts.empty?
    @repp_logs = @q.result.page(params[:page])
  end

  def show
    @repp_log = ApiLog::ReppLog.find(params[:id])
  end
end
