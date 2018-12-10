module Serializers
  module RegistrantApi
    class Contact
      attr_reader :contact

      def initialize(contact)
        @contact = contact
      end

      def to_json
        {
          id: contact.uuid,
          name: contact.name,
          code: contact.code,
          ident: {
            code: contact.ident,
            type: contact.ident_type,
            country_code: contact.ident_country_code,
          },
          email: contact.email,
          phone: contact.phone,
          fax: contact.fax,
          address: {
            street: contact.street,
            zip: contact.zip,
            city: contact.city,
            state: contact.state,
            country_code: contact.country_code,
          },
          auth_info: contact.auth_info,
          statuses: contact.statuses,
          disclosed_attributes: contact.disclosed_attributes,
        }
      end
    end
  end
end
