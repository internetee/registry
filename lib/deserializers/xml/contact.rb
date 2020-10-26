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
          org_name: if_present('postalInfo org'),
          email: if_present('email'),
          fax: if_present('fax'),
          phone: if_present('voice'),
          id: if_present('id'),

          # Address fields
          city: if_present('postalInfo addr city'),
          zip: if_present('postalInfo addr pc'),
          street: if_present('postalInfo addr street'),
          state: if_present('postalInfo addr sp'),
          country_code: if_present('postalInfo addr cc'),

          # Auth info
          auth_info: if_present('authInfo pw'),

          # statuses
          statuses_to_add: statuses_to_add,
          statuses_to_remove: statuses_to_remove,
        }

        attributes.compact
      end

      def if_present(css_path)
        return if frame.css(css_path).blank?

        frame.css(css_path).text
      end

      def statuses_to_add
        statuses_frame = frame.css('add')
        return if statuses_frame.blank?

        statuses_frame.css('status').map do |status|
          status['s']
        end
      end

      def statuses_to_remove
        statuses_frame = frame.css('rem')
        return if statuses_frame.blank?

        statuses_frame.css('status').map do |status|
          status['s']
        end
      end
    end
  end
end
