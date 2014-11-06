class Epp::CommandsController < ApplicationController
  include Epp::Common
  include Epp::DomainsHelper
  include Epp::ContactsHelper
  include Shared::UserStamper
  helper WhodunnitHelper

  layout false

  private

  def poll
    @message = current_epp_user.registrar.messages.last
    if @message.attached_obj_type && @message.attached_obj_id
      @object = Object.const_get(@message.attached_obj_type).find(@message.attached_obj_id)
    end
    render 'epp/poll'
  end

  def create
    send("create_#{OBJECT_TYPES[params_hash['epp']['xmlns:ns2']]}")
  end

  def renew
    send("renew_#{OBJECT_TYPES[params_hash['epp']['xmlns:ns2']]}")
  end

  def transfer
    send("transfer_#{OBJECT_TYPES[params_hash['epp']['xmlns:ns2']]}")
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

  def user_for_paper_trail
    current_epp_user ? "#{current_epp_user.id}-EppUser" : nil
  end
end
