# coding: utf-8
require 'savon'
=begin

Estonian Business registry provides information about registered companies via xml (SOAP over HTTPS).

Note:
  The SSL endpoint certificate is self signed.

Documentation: 
  http://www.rik.ee/et/e-ariregister/xml-teenus
  Specifications are in Eng and Est
  User contract required

Testing:
  https://demo-ariregxml.rik.ee:447/testariport/?wsdl
  http://demo-ariregxml.rik.ee:81 
  https://demo-ariregxml.rik.ee:447

Live service:
  https://ariregxml.rik.ee/ariport/?wsdl
  https://ariregxml.rik.ee/

Implements Soap::Arireg # associated_businesses
   8. arireg.paringesindus_v4
   Rights of representation of all persons related to the company (newer)
   http://www2.rik.ee/schemas/xtee/arireg/live/paringesindus_v4.xsd
   expects personal id code, to fetch list of registered  business id codes
   returning {ident: person, ident_country_code: ... associated_businesses: [...id_codes...]}

=end

# do some SSL set up?
# ssl_version
# ssl_verify_mode
# ssl_cert_key_file
# ssl_cert_key
# ssl_cert_key_password
# ssl_cert_file
# ssl_cert
# ssl_ca_cert_file
# ssl_ca_cert

module Soap
  class Arireg
    class << self
      attr_accessor :wsdl, :host, :username, :password
    end
    
    def initialize
      if self.class.username.nil?
        if Rails.application.secrets.key?(:arireg)
          arireg = Rails.application.secrets[:arireg].with_indifferent_access
          self.class.username = arireg[:username]
          self.class.password = arireg[:password]
          if self.class.wsdl.nil?         # no override of config/environments/* ?
            self.class.wsdl = arireg[:wsdl]
            self.class.host = arireg[:host]
          end
        else
          self.class.username = ENV['arireg_username']
          self.class.password = ENV['arireg_password']
        end
      end
      if self.class.wsdl.nil?
        self.class.wsdl = ENV['arireg_wsdl']
        self.class.host = ENV['arireg_host']
      end

      # note Savon has error if https w/non-standard port,
      # use non-standard force to pre-set endpoint
      @client = Savon.client(wsdl: self.class.wsdl,
                             host: self.class.host,
                      endpoint: "#{self.class.host}/cgi-bin/consumer_proxy")
      @session = nil
    end

    # retrieve business id codes for business that a person has a legal role
    def associated_businesses(ident, ident_cc = 'EST')
      begin
        response = @client.call :paringesindus_v4, message: body(
                                  'fyysilise_isiku_kood' => ident,
                                  'fyysilise_isiku_koodi_riik' => ident_cc
                                )
        content = extract response, :paringesindus_v4_response
        unless content.blank?
          if content[:ettevotjad].key? :item
            business_ident = items(content, :ettevotjad).map do |item|
              #puts "#{item[:ariregistri_kood]}\t#{item[:arinimi]}\t#{item[:staatus]}  #{item[:oiguslik_vorm]}\t"
              item[:ariregistri_kood]
            end
            {
             ident: ident,
             ident_country_code: ident_cc,
             # ident_type: 'priv',
             retrieved_on: Time.now,
             associated_businesses: business_ident
            }
          end
        end
      rescue Savon::SOAPFault => fault
        Rails.logger.error "#{fault} Äriregister arireg #{self.class.username} at #{self.class.host }"
        nil
      rescue HTTPI::SSLError => ssl_error
        Rails.logger.error "#{ssl_error} at #{self.class.host}"
        nil
      rescue SocketError => sock
        Rails.logger.error "#{sock}"
        nil
      end
    end
    
    def debug
      @client.globals.log_level :debug
      @client.globals.log true
      @client.globals.pretty_print_xml true
      @client
    end

    private

    # add required elements to request
    def body(args)
      if @session.nil? 
        args['ariregister_kasutajanimi'] = self.class.username
        args['ariregister_parool'] = self.class.password
      else
        args['ariregister_sessioon'] = @session
      end
      {keha: args}
    end
    
    def extract(response, element)
      # response envelope body has again header/body under element; header is user and password returned
      response.hash[:envelope][:body][element][:keha]
    end

    def items(content, parent)
      items = content[parent][:item]
      items.is_a?(Array) ? items : [items]
    end
    
  end
end
