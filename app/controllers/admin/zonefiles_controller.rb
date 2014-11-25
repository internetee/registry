class Admin::ZonefilesController < ApplicationController
  # TODO: Refactor this
  # rubocop:disable Metrics/MethodLength
  def index

  end

  def create
    if ZonefileSetting.pluck(:origin).include?(params[:origin])

      @zonefile = ActiveRecord::Base.connection.execute(
        "select generate_zonefile('#{params[:origin]}')"
      )[0]['generate_zonefile']

      send_data @zonefile, filename: "#{params[:origin]}.txt"
    else
      flash[:alert] = 'Origin not supported'
      redirect_to :back
    end
  end
end
