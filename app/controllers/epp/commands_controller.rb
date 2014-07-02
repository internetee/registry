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
    ph = get_params_hash('create create')[:create]
    type = OBJECT_TYPES[ph[:schemaLocation]]
    send("create_#{type}")
  end

  def check
    ph = get_params_hash('check check')[:check]
    type = OBJECT_TYPES[ph[:schemaLocation]]
    send("check_#{type}")
  end
end
