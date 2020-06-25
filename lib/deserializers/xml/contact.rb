module Deserializers
  module Xml
    class Contact
      attr_reader :frame

      def initialize(frame)
        @frame = frame
      end

      def call
        attributes = {
          name: if_present('postalInfo name'),
          org: if_present('postalInfo org'),
          email: if_present('email'),
          fax: if_present('fax'),
          phone: if_present('voice'),

          # Address fields
          city: if_present('postalInfo addr city'),
          zip: if_present('postalInfo addr pc'),
          street: if_present('postalInfo addr street'),
          state: if_present('postalInfo addr sp'),
          country_code: if_present('postalInfo addr cc'),

          # Auth info
          auth_info: if_present('authInfo pw'),
        }

        attributes.compact
      end

      def if_present(css_path)
        return unless frame.css(css_path).present?

        frame.css(css_path).text
      end
    end
  end
end
