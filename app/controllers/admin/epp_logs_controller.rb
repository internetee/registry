class Admin::EppLogsController < ApplicationController
  load_and_authorize_resource class: ApiLog::EppLog

  def index
    @epp_logs = ApiLog::EppLog.order(id: :desc).page(params[:page])
  end

  def show
    @epp_log = ApiLog::EppLog.find(params[:id])
  end
end
