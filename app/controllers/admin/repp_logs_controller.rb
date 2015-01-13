class Admin::ReppLogsController < ApplicationController
  load_and_authorize_resource class: ApiLog::ReppLog

  def index
    @repp_logs = ApiLog::ReppLog.order(id: :desc).page(params[:page])
  end

  def show
    @repp_log = ApiLog::ReppLog.find(params[:id])
  end
end
