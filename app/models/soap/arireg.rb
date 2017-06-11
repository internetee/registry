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

    class NotAvailableError < StandardError
      attr_accessor :json
      def initialize(params)
        params[:message] = "#{I18n.t(:business_registry_service_not_available)}" unless params.key? :message
        @json = params

        super(params)
      end
    end

    class << self
      attr_accessor :wsdl, :host, :username, :password
    end
    
    def initialize
      if self.class.username.nil?
        self.class.username = ENV['arireg_username']
        self.class.password = ENV['arireg_password']
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
        msg = {
            'fyysilise_isiku_kood'       => ident,
            'fyysilise_isiku_koodi_riik' => country_code_3(ident_cc)
        }
        Rails.logger.info "[Ariregister] Request sent with data: #{msg.inspect}"

        response = @client.call :paringesindus_v4, message: body(msg)
        content = extract response, :paringesindus_v4_response
        Rails.logger.info "[Ariregister] Got response with data: #{content.inspect}"

        if content.present? && content[:ettevotjad].key?(:item)
          business_ident = items(content, :ettevotjad).map{|item| item[:ariregistri_kood]}
        else
          business_ident = []
        end

        {
            ident: ident,
            ident_country_code: ident_cc,
            # ident_type: 'priv',
            retrieved_on: Time.now,
            associated_businesses: business_ident
        }
      rescue Savon::SOAPFault => fault
        Rails.logger.error "[Ariregister] #{fault} Äriregister arireg #{self.class.username} at #{self.class.host }"
        raise NotAvailableError.new(exception: fault)
      rescue HTTPI::SSLError => ssl_error
        Rails.logger.error "[Ariregister] #{ssl_error} at #{self.class.host}"
        raise NotAvailableError.new(exception: ssl_error)
      rescue SocketError => sock
        Rails.logger.error "[Ariregister] #{sock}"
        raise NotAvailableError.new(exception: sock)
      end
    end
    
    def debug
      @client.globals.log_level :debug
      @client.globals.log true
      @client.globals.pretty_print_xml true
      @debug = true
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

    # TLA --- three letter acronym required not two letter acronym, transform
    def country_code_3(code)
      if code.length == 2
        code = CC2X3[code]
        raise NotAvailableError.new(message: 'Unrecognized Country') if code.nil?
      end
      code
    end

    def extract(response, element)
      # response envelope body has again header/body under element; header is user and password returned
      response.hash[:envelope][:body][element][:keha]
    end

    def items(content, parent)
      items = content[parent][:item]
      items.is_a?(Array) ? items : [items]
    end

    CC2X3 = {"AF"=>"AFG", "AX"=>"ALA", "AL"=>"ALB", "DZ"=>"DZA", "AS"=>"ASM",
             "AD"=>"AND", "AO"=>"AGO", "AI"=>"AIA", "AQ"=>"ATA", "AG"=>"ATG",
             "AR"=>"ARG", "AM"=>"ARM", "AW"=>"ABW", "AU"=>"AUS", "AT"=>"AUT",
             "AZ"=>"AZE", "BS"=>"BHS", "BH"=>"BHR", "BD"=>"BGD", "BB"=>"BRB",
             "BY"=>"BLR", "BE"=>"BEL", "BZ"=>"BLZ", "BJ"=>"BEN", "BM"=>"BMU",
             "BT"=>"BTN", "BO"=>"BOL", "BQ"=>"BES", "BA"=>"BIH", "BW"=>"BWA",
             "BV"=>"BVT", "BR"=>"BRA", "IO"=>"IOT", "BN"=>"BRN", "BG"=>"BGR",
             "BF"=>"BFA", "BI"=>"BDI", "CV"=>"CPV", "KH"=>"KHM", "CM"=>"CMR",
             "CA"=>"CAN", "KY"=>"CYM", "CF"=>"CAF", "TD"=>"TCD", "CL"=>"CHL",
             "CN"=>"CHN", "CX"=>"CXR", "CC"=>"CCK", "CO"=>"COL", "KM"=>"COM",
             "CD"=>"COD", "CG"=>"COG", "CK"=>"COK", "CR"=>"CRI", "CI"=>"CIV",
             "HR"=>"HRV", "CU"=>"CUB", "CW"=>"CUW", "CY"=>"CYP", "CZ"=>"CZE",
             "DK"=>"DNK", "DJ"=>"DJI", "DM"=>"DMA", "DO"=>"DOM", "EC"=>"ECU",
             "EG"=>"EGY", "SV"=>"SLV", "GQ"=>"GNQ", "ER"=>"ERI", "EE"=>"EST",
             "ET"=>"ETH", "FK"=>"FLK", "FO"=>"FRO", "FJ"=>"FJI", "FI"=>"FIN",
             "FR"=>"FRA", "GF"=>"GUF", "PF"=>"PYF", "TF"=>"ATF", "GA"=>"GAB",
             "GM"=>"GMB", "GE"=>"GEO", "DE"=>"DEU", "GH"=>"GHA", "GI"=>"GIB",
             "GR"=>"GRC", "GL"=>"GRL", "GD"=>"GRD", "GP"=>"GLP", "GU"=>"GUM",
             "GT"=>"GTM", "GG"=>"GGY", "GN"=>"GIN", "GW"=>"GNB", "GY"=>"GUY",
             "HT"=>"HTI", "HM"=>"HMD", "VA"=>"VAT", "HN"=>"HND", "HK"=>"HKG",
             "HU"=>"HUN", "IS"=>"ISL", "IN"=>"IND", "ID"=>"IDN", "IR"=>"IRN",
             "IQ"=>"IRQ", "IE"=>"IRL", "IM"=>"IMN", "IL"=>"ISR", "IT"=>"ITA",
             "JM"=>"JAM", "JP"=>"JPN", "JE"=>"JEY", "JO"=>"JOR", "KZ"=>"KAZ",
             "KE"=>"KEN", "KI"=>"KIR", "KP"=>"PRK", "KR"=>"KOR", "KW"=>"KWT",
             "KG"=>"KGZ", "LA"=>"LAO", "LV"=>"LVA", "LB"=>"LBN", "LS"=>"LSO",
             "LR"=>"LBR", "LY"=>"LBY", "LI"=>"LIE", "LT"=>"LTU", "LU"=>"LUX",
             "MO"=>"MAC", "MK"=>"MKD", "MG"=>"MDG", "MW"=>"MWI", "MY"=>"MYS",
             "MV"=>"MDV", "ML"=>"MLI", "MT"=>"MLT", "MH"=>"MHL", "MQ"=>"MTQ",
             "MR"=>"MRT", "MU"=>"MUS", "YT"=>"MYT", "MX"=>"MEX", "FM"=>"FSM",
             "MD"=>"MDA", "MC"=>"MCO", "MN"=>"MNG", "ME"=>"MNE", "MS"=>"MSR",
             "MA"=>"MAR", "MZ"=>"MOZ", "MM"=>"MMR", "NA"=>"NAM", "NR"=>"NRU",
             "NP"=>"NPL", "NL"=>"NLD", "NC"=>"NCL", "NZ"=>"NZL", "NI"=>"NIC",
             "NE"=>"NER", "NG"=>"NGA", "NU"=>"NIU", "NF"=>"NFK", "MP"=>"MNP",
             "NO"=>"NOR", "OM"=>"OMN", "PK"=>"PAK", "PW"=>"PLW", "PS"=>"PSE",
             "PA"=>"PAN", "PG"=>"PNG", "PY"=>"PRY", "PE"=>"PER", "PH"=>"PHL",
             "PN"=>"PCN", "PL"=>"POL", "PT"=>"PRT", "PR"=>"PRI", "QA"=>"QAT",
             "RE"=>"REU", "RO"=>"ROU", "RU"=>"RUS", "RW"=>"RWA", "BL"=>"BLM",
             "SH"=>"SHN", "KN"=>"KNA", "LC"=>"LCA", "MF"=>"MAF", "PM"=>"SPM",
             "VC"=>"VCT", "WS"=>"WSM", "SM"=>"SMR", "ST"=>"STP", "SA"=>"SAU",
             "SN"=>"SEN", "RS"=>"SRB", "SC"=>"SYC", "SL"=>"SLE", "SG"=>"SGP",
             "SX"=>"SXM", "SK"=>"SVK", "SI"=>"SVN", "SB"=>"SLB", "SO"=>"SOM",
             "ZA"=>"ZAF", "GS"=>"SGS", "SS"=>"SSD", "ES"=>"ESP", "LK"=>"LKA",
             "SD"=>"SDN", "SR"=>"SUR", "SJ"=>"SJM", "SZ"=>"SWZ", "SE"=>"SWE",
             "CH"=>"CHE", "SY"=>"SYR", "TW"=>"TWN", "TJ"=>"TJK", "TZ"=>"TZA",
             "TH"=>"THA", "TL"=>"TLS", "TG"=>"TGO", "TK"=>"TKL", "TO"=>"TON",
             "TT"=>"TTO", "TN"=>"TUN", "TR"=>"TUR", "TM"=>"TKM", "TC"=>"TCA",
             "TV"=>"TUV", "UG"=>"UGA", "UA"=>"UKR", "AE"=>"ARE", "GB"=>"GBR",
             "UM"=>"UMI", "US"=>"USA", "UY"=>"URY", "UZ"=>"UZB", "VU"=>"VUT",
             "VE"=>"VEN", "VN"=>"VNM", "VG"=>"VGB", "VI"=>"VIR", "WF"=>"WLF",
             "EH"=>"ESH", "YE"=>"YEM", "ZM"=>"ZMB", "ZW"=>"ZWE"}
  end
end
