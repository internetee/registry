require 'test_helper'

class EppResponseTest < ActiveSupport::TestCase
  def test_creates_new_response_from_xml_doc
    xml = <<-XML
      <?xml version="1.0" encoding="UTF-8"?>
      <epp xmlns="https://epp.tld.ee/schema/epp-ee-1.0.xsd" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xsi:schemaLocation="lib/schemas/epp-ee-1.0.xsd">
        <response>
          <result code="1000">
            <msg>any</msg>
          </result>
        </response>
      </epp>
    XML

    assert_kind_of Epp::Response, Epp::Response.xml(xml)
  end

  def test_code_predicate
    present_code = Epp::Response::Result::Code.key(:completed_successfully)
    absent_code = Epp::Response::Result::Code.key(:required_parameter_missing)

    result = Epp::Response::Result.new(code: present_code)
    response = Epp::Response.new(results: [result])

    assert response.code?(present_code)
    assert_not response.code?(absent_code)
  end
end
