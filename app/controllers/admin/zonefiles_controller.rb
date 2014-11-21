class Admin::ZonefilesController < ApplicationController
  # TODO: Refactor this
  # rubocop:disable Metrics/MethodLength
  def index
    @zonefile = ActiveRecord::Base.connection.execute("select generate_zonefile('ee')")[0]['generate_zonefile']
    send_data @zonefile, filename: 'zonefile-1000.txt'
  end
end
