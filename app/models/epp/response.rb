module EPP
  class Response
    attr_accessor :results

    def self.from_xml(xml)
      xml_doc = Nokogiri::XML(xml)
      response = self.new

      result_elements = xml_doc.css('result')

      result_elements.each do |result_element|
        response.results << Result.new(result_element[:code].to_s, result_element.text.strip)
      end

      response
    end

    def initialize
      @results = []
    end
  end
end
