module Deserializers
  module Xml
    class Domain
      attr_reader :frame

      def initialize(frame)
        @frame = frame
      end

      def call
        attributes = {
          name: if_present('name'),
          registrar_id: current_user.registrar.id,
          reserved_pw: if_present('reserved > pw'),
          period: Integer(frame.css('period').text, 1),
          period_unit: parsed_frame.css('period').first ? parsed_frame.css('period').first[:unit] : 'y'
        }

        pw = frame.css('authInfo > pw').text
        attributes[:transfer_code] = pw if pw.present?
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
