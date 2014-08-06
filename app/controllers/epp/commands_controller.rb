class Epp::CommandsController < ApplicationController
  include Epp::Common
  include Epp::DomainsHelper
  include Epp::ContactsHelper
  include Shared::UserStamper

  private
  def create
    send("create_#{OBJECT_TYPES[params_hash['epp']['xmlns:ns2']]}")
  end

  def check
    send("check_#{OBJECT_TYPES[params_hash['epp']['xmlns:ns2']]}")
  end

  def delete
    send("delete_#{OBJECT_TYPES[params_hash['epp']['xmlns:ns2']]}")
  end

  def info
    send("info_#{OBJECT_TYPES[params_hash['epp']['xmlns:ns2']]}")
  end

  def update
    send("update_#{OBJECT_TYPES[params_hash['epp']['xmlns:ns2']]}")
  end
end
