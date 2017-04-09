module Matchers
  module EPP
    class Code
      def initialize(expected)
        @expected = expected
      end

      def matches?(response)
        @xml = response.body
        actual == expected
      end

      def failure_message
        "Expected EPP code of #{expected}, got #{actual} (#{code_description})"
      end

      def description
        "have EPP code of #{expected}"
      end

      private

      attr_reader :xml
      attr_reader :expected

      def actual
        xml_document.xpath('//xmlns:result').first['code'].to_i
      end

      def code_description
        xml_document.css('result msg').text
      end

      def xml_document
        @xml_document ||= Nokogiri::XML(xml)
      end
    end
  end
end
