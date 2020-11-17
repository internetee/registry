module Serializers
  module Repp
    class Contact
      attr_reader :contact

      def initialize(contact, show_address:)
        @contact = contact
        @show_address = show_address
      end

      def to_json(obj = contact)
        json = { id: obj.code, name: obj.name, ident: ident,
                 email: obj.email, phone: obj.phone, fax: obj.fax,
                 auth_info: obj.auth_info, statuses: obj.statuses,
                 disclosed_attributes: obj.disclosed_attributes }

        json[:address] = address if @show_address

        json
      end

      def ident
        {
          code: contact.ident,
          type: contact.ident_type,
          country_code: contact.ident_country_code,
        }
      end

      def address
        { street: contact.street, zip: contact.zip, city: contact.city,
          state: contact.state, country_code: contact.country_code }
      end
    end
  end
end
