class Admin::ZonefilesController < ApplicationController
  authorize_resource class: false
  # TODO: Refactor this

  def create
    if ZonefileSetting.origins.include?(params[:origin])

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
