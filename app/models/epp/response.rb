module Epp
  class Response
    attr_reader :results

    def self.xml(xml)
      xml_doc = Nokogiri::XML(xml)
      result_elements = xml_doc.css('result')
      results = []

      result_elements.each do |result_element|
        code_value = result_element[:code]
        code = Result::Code.new(code_value)
        results << Result.new(code: code)
      end

      new(results: results)
    end

    def initialize(results:)
      @results = results
    end

    def code?(code)
      results.any? { |result| result.code == code }
    end
  end
end
