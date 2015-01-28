class Admin::EppLogsController < ApplicationController
  load_and_authorize_resource class: ApiLog::EppLog

  def index
    @q = ApiLog::EppLog.search(params[:q])
    @q.sorts = 'id desc' if @q.sorts.empty?
    @epp_logs = @q.result.page(params[:page])
  end

  def show
    @epp_log = ApiLog::EppLog.find(params[:id])
  end
end
