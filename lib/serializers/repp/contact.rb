module Serializers
  module Repp
    class Contact
      attr_reader :contact

      def initialize(contact, show_address:)
        @contact = contact
        @show_address = show_address
      end

      def to_json
        json = {
          id: contact.code,
          name: contact.name,
          ident: {
            code: contact.ident,
            type: contact.ident_type,
            country_code: contact.ident_country_code,
          },
          email: contact.email,
          phone: contact.phone,
          fax: contact.fax,
          auth_info: contact.auth_info,
          statuses: contact.statuses,
          disclosed_attributes: contact.disclosed_attributes,
        }

        return json unless @show_address

        json[:address] = {
          street: contact.street,
          zip: contact.zip,
          city: contact.city,
          state: contact.state,
          country_code: contact.country_code,
        }

        json
      end
    end
  end
end
