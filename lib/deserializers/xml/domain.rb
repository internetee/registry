module Deserializers
  module Xml
    class Domain
      attr_reader :frame
      attr_reader :registrar

      def initialize(frame, registrar)
        @frame = frame
        @registrar = registrar
      end

      def call
        attributes = {
          name: if_present('name'),
          registrar_id: registrar,
          registrant_id: if_present('registrant'),
          reserved_pw: if_present('reserved > pw'),
          period: frame.css('period').text.present? ? Integer(frame.css('period').text) : 1,
          period_unit: frame.css('period').first ? frame.css('period').first[:unit] : 'y',
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
