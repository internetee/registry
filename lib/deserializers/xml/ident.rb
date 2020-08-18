module Deserializers
  module Xml
    class Ident
      attr_reader :frame

      def initialize(frame)
        @frame = frame.css('ident').first
      end

      def call
        if valid?
          {
            ident: frame.text,
            ident_type: frame.attr('type'),
            ident_country_code: frame.attr('cc'),
          }
        else
          {}
        end
      end

      private

      def valid?
        return false if frame.blank?
        return false if frame.try('text').blank?
        return false if frame.attr('type').blank?
        return false if frame.attr('cc').blank?

        true
      end
    end
  end
end
