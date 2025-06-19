module Admin
  class ZonefilesController < BaseController
    authorize_resource class: false
    # TODO: Refactor this

    def create
      if ::DNS::Zone.origins.include?(params[:origin])
        @zonefile = ActiveRecord::Base.connection.exec_query(
          "select generate_zonefile($1)",
          'Generate Zonefile',
          [[nil, params[:origin]]]
        )[0]['generate_zonefile']

        send_data @zonefile, filename: "#{params[:origin]}.txt"
      else
        flash[:alert] = 'Origin not supported'
        redirect_back(fallback_location: root_path)
      end
    end
  end
end
