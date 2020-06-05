module Deserializers
  module Xml
    # Given a nokogiri frame, extract information about legal document from it.
    class LegalDocument
      attr_reader :frame

      def initialize(frame)
        @frame = frame
      end

      def call
        ld = frame.css('legalDocument').first
        return unless ld

        {
          body: ld.text,
          type: ld['type']
        }
      end
    end
  end
end
