class Epp::CommandsController < ApplicationController
  include Epp::Common
  include Epp::CommandsHelper
  include Epp::DomainsHelper

  OBJECT_TYPES = {
    'http://www.nic.cz/xml/epp/domain-1.4 domain-1.4.xsd' => 'domain'
  }

  private
  def create
    type = OBJECT_TYPES[parsed_frame.css('create create').attr('schemaLocation').value]
    send("create_#{type}")
  end
end
