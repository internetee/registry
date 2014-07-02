class Epp::CommandsController < ApplicationController
  include Epp::Common
  include Epp::DomainsHelper
  include Epp::ContactsHelper

  OBJECT_TYPES = {
    'http://www.nic.cz/xml/epp/domain-1.4 domain-1.4.xsd' => 'domain',
    'http://www.nic.cz/xml/epp/contact-1.6 contact-1.6.xsd' => 'contact'
  }

  private
  def create
    type = OBJECT_TYPES[parsed_frame.css('create create').attr('schemaLocation').value]
    send("create_#{type}")
  end

  def check
    type = OBJECT_TYPES[parsed_frame.css('check check').attr('schemaLocation').value]
    send("check_#{type}")
  end
end
