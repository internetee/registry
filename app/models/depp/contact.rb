module Depp
  class Contact
    include ActiveModel::Model
    include DisableHtml5Validation

    attr_accessor :id, :name, :email, :phone, :org_name,
      :ident, :ident_type, :ident_country_code, 
      :street, :city, :zip, :state, :country_code,
      :password, :legal_document, :statuses, :code

    DISABLED = 'Disabled'
    DISCLOSURE_TYPES = [DISABLED, '1', '0']
    TYPES = %w( bic priv birthday )
    SELECTION_TYPES = [
      ['Business code', 'bic'],
      ['Personal identification code', 'priv'],
      ['Birthday', 'birthday']
    ]

    class << self
      attr_reader :epp_xml, :user

      # rubocop: disable Metrics/MethodLength
      def new_from_params(params)
        new(
          id: params[:code],
          code: params[:code],
          email: params[:email],
          phone: params[:phone],
          ident: params[:ident],
          ident_type: params[:ident_type],
          ident_country_code: params[:ident_country_code],

          # postalInfo
          name: params[:name],
          org_name: params[:org_name],

          # address
          street:       params[:street],
          city:         params[:city],
          zip:          params[:zip],
          state:        params[:state],
          country_code: params[:country_code]
        )
      end
      # rubocop: enable Metrics/MethodLength

      def find_by_id(id)
        data = info_xml(id)

        res = data.css('epp response resData infData')
        ext = data.css('epp response extension')
        new(
          id: res.css('id').text,
          code: res.css('id').text,
          email: res.css('email').text,
          phone: res.css('voice').text,
          ident: ext.css('ident').text,
          ident_type: ext.css('ident').first.try(:attributes).try(:[], 'type').try(:value),
          ident_country_code: ext.css('ident').first.try(:attributes).try(:[], 'cc').try(:value),

          # postalInfo
          name: res.css('postalInfo name').text,
          org_name: res.css('postalInfo org').text,

          # address
          street:       res.css('postalInfo addr street').text,
          city:         res.css('postalInfo addr city').text,
          zip:          res.css('postalInfo addr pc').text,
          state:        res.css('postalInfo addr sp').text,
          country_code: res.css('postalInfo addr cc').text,
          
          # authInfo
          password: res.css('authInfo pw').text,

          # statuses
          statuses: data.css('status').map { |s| [s['s'], s.text] }
        )
      end

      def user=(user)
        @user = user
        @epp_xml = EppXml::Contact.new(cl_trid_prefix: user.tag)
      end

      def info_xml(id, password = nil)
        xml = epp_xml.info(
          id: { value: id },
          authInfo: { pw: { value: password } }
        )
        user.request(xml)
      end

      def construct_check_hash_from_data(data)
        res = data.css('epp response resData chkData cd')
        @contacts = []
        res.each do |_r|
          id = res.css('id').try(:text)
          reason = res.css('reason').present? ? res.css('reason').text : I18n.t(:available)
          @contacts << { id: id, reason: reason  }
        end
        @contacts
      end

      def contact_id_from_xml(data)
        id = data.css('epp response resData creData id').text
        id.blank? ? nil : id
      end

      def construct_create_disclosure_xml(cph, flag)
        xml = { disclose: {} }
        cph.each do |k, v|
          xml[:disclose][k] = {}
          xml[:disclose][k][:value] = v
        end
        xml[:disclose][:attrs] = {}
        xml[:disclose][:attrs][:flag] = flag
        xml.with_indifferent_access
      end

      def extract_disclosure_hash(cpd) # cpd = contact_params[:disclose]
        return {} unless cpd
        cpd = cpd.delete_if { |k, v| v if v != '1' && k == 'flag' }
        cpd
      end

      def extract_info_disclosure(data)
        hash = {}
        data.css('disclose').each do |d|
          flag = d.attributes['flag'].value
          next unless flag
          hash[flag] = {}
          d.children.each do |c|
            hash[flag][c.name] = flag if %w( name email fax voice addr org_name ).include?(c.name)
          end
        end
        hash
      end
    end

    def initialize(attributes = {})
      super
      self.country_code = 'EE'       if country_code.blank?
      self.ident_type = 'bic'        if ident_type.blank?
      self.ident_country_code = 'EE' if ident_country_code.blank?
    end

    def save
      create_xml = Depp::Contact.epp_xml.create(
        {
          id: { value: code },
          email: { value: email },
          voice: { value: phone },
          postalInfo: {
            name: { value: name },
            org:  { value: org_name },
            addr: {
              street: { value: street },
              city:   { value: city },
              pc:     { value: zip },
              sp:     { value: state },
              cc:     { value: country_code }
            }
          }
        }, 
        extension_xml
      )
      data = Depp::Contact.user.request(create_xml)
      self.id = data.css('id').text
      handle_errors(data)
    end

    # rubocop: disable Metrics/MethodLength
    def update_attributes(params)
      self.ident_country_code = params[:ident_country_code]
      self.ident_type   = params[:ident_type]
      self.ident        = params[:ident]

      self.name  = params[:name]
      self.email = params[:email]
      self.phone = params[:phone]

      self.org_name     = params[:org_name]
      self.street       = params[:street]
      self.city         = params[:city]
      self.zip          = params[:zip]
      self.state        = params[:state]
      self.country_code = params[:country_code]

      update_xml = Depp::Contact.epp_xml.update(
        {
          id: { value: id },
          chg: {
            voice: { value: phone },
            email: { value: email },
            postalInfo: {
              name: { value: name },
              org:  { value: org_name },
              addr: {
                street: { value: street },
                city:   { value: city },
                pc:     { value: zip },
                sp:     { value: state },
                cc:     { value: country_code }
              }
            }
          },
          authInfo: {
            pw: { value: password }
          }
        },
        extension_xml
      )
      data = Depp::Contact.user.request(update_xml)
      handle_errors(data)
    end
    # rubocop: enable Metrics/MethodLength

    def delete
      delete_xml = Contact.epp_xml.delete(
        {
          id: { value: id },
          authInfo: { pw: { value: password } }
        },
        extension_xml
      )
      data = Depp::Contact.user.request(delete_xml)
      handle_errors(data)
    end

    def extension_xml
      xml = { _anonymus: [] }
      ident = ident_xml[:_anonymus].try(:first)
      legal = legal_document_xml[:_anonymus].try(:first)
      xml[:_anonymus] << ident if ident.present?
      xml[:_anonymus] << legal if legal.present?
      xml
    end

    def ident_xml
      {
        _anonymus: [
          ident: { value: ident, attrs: { type: ident_type, cc: ident_country_code } }
        ]
      }
    end

    def legal_document_xml
      return {} if legal_document.blank?

      type = legal_document.original_filename.split('.').last.downcase
      { 
        _anonymus: [
          legalDocument: { value: Base64.encode64(legal_document.read), attrs: { type: type } }
        ]
      }
    end

    def check(id)
      xml = epp_xml.check(id: { value: id })
      current_user.request(xml)
    end

    def country_name
      Country.new(country_code)
    end

    def bic?
      ident_type == 'bic'
    end

    def priv?
      ident_type == 'priv'
    end

    def persisted? 
      id.present?
    end

    def handle_errors(data)
      data.css('result').each do |x|
        success_codes = %(1000, 1300, 1301)
        next if success_codes.include?(x['code'])
        
        message = "#{x.css('msg').text} #{x.css('value').text}"
        attr = message.split('[').last.strip.sub(']', '') if message.include?('[')
        attr = :base if attr.nil?
        attr = 'phone' if attr == 'voice'
        attr = 'zip' if attr == 'pc'
        errors.add(attr, message) 
      end
      errors.blank?
    end
  end
end
