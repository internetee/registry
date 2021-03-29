module Deserializers
  module Xml
    class DomainDelete
      attr_reader :frame

      def initialize(frame)
        @frame = frame
      end

      def call
        obj = {}
        obj[:name] = frame.css('name')&.text
        verify = frame.css('delete').children.css('delete').attr('verified').to_s.downcase == 'yes'
        obj[:delete] = { verified: verify }

        obj
      end
    end
  end
end
