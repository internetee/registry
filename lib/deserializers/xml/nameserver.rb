module Deserializers
  module Xml
    class Nameserver
      attr_reader :frame

      def initialize(frame)
        @frame = frame
      end

      def call
        {
          hostname: frame.css('hostName').text,
          ipv4: frame.css('hostAddr[ip="v4"]').map(&:text).compact,
          ipv6: frame.css('hostAddr[ip="v6"]').map(&:text).compact
        }
      end
    end

    class Nameservers
      attr_reader :frame

      def initialize(frame)
        @frame = frame
      end

      def call
        res = []
        frame.css('hostAttr').each do |ns|
          ns = Deserializers::Xml::Nameserver.new(ns).call
          res << ns.delete_if { |_k, v| v.blank? }
        end

        res
      end
    end
  end
end
