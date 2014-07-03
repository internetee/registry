class Epp::CommandsController < ApplicationController
  include Epp::Common
  include Epp::DomainsHelper
  include Epp::ContactsHelper

  private
  def create
    send("create_#{OBJECT_TYPES[params_hash['epp']['xmlns:ns2']]}")
  end

  def check
    send("check_#{OBJECT_TYPES[params_hash['epp']['xmlns:ns2']]}")
  end
end
