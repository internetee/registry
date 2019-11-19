require 'test_helper'

class EppHelloTest < EppTestCase
  def test_anonymous_user_is_able_to_access
    request_xml = <<-XML
      <?xml version="1.0" encoding="UTF-8" standalone="no"?>
      <epp xmlns="https://epp.tld.ee/schema/epp-ee-1.0.xsd">
        <hello/>
      </epp>
    XML

    get epp_hello_path, params: { frame: request_xml },
        headers: { 'HTTP_COOKIE' => 'session=non-existent' }

    response_xml = Nokogiri::XML(response.body)
    assert_equal 'EPP server (EIS)', response_xml.at_css('greeting > svID').text
  end
end
