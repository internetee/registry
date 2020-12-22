module Serializers
  module RegistrantApi
    class Contact
      attr_reader :contact, :links

      def initialize(contact, links)
        @contact = contact
        @links = links
      end

      def to_json(_obj = nil)
        obj = {
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

        obj[:links] = contact.related_domains if @links

        obj
      end
    end
  end
end
