class Epp::CommandsController < ApplicationController
  include Epp::Common
  include Epp::DomainsHelper
  include Epp::ContactsHelper

  OBJECT_TYPES = {
    'urn:ietf:params:xml:ns:contact-1.0' => 'contact',
    'urn:ietf:params:xml:ns:domain-1.0' => 'domain'
  }

  private
  def create
    send("create_#{OBJECT_TYPES[params_hash['epp']['xmlns:ns2']]}")
  end

  def check
    send("check_#{OBJECT_TYPES[params_hash['epp']['xmlns:ns2']]}")
  end
end
