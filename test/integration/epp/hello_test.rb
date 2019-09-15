require 'test_helper'

class EppHelloTest < EppTestCase
  def test_authenticated_user_can_access
    post '/epp/session/hello', { frame: request_xml }, 'HTTP_COOKIE' => 'session=api_bestnames'

    response_xml = Nokogiri::XML(response.body)
    assert_equal 'EPP server (EIS)', response_xml.at_css('greeting > svID').text
  end

  def test_anonymous_user_cannot_access
    post '/epp/session/hello', { frame: request_xml }, 'HTTP_COOKIE' => 'session=non-existent'
    assert_epp_response :authorization_error
  end

  private

  def request_xml
    <<-XML
      <?xml version="1.0" encoding="UTF-8" standalone="no"?>
      <epp xmlns="https://epp.tld.ee/schema/epp-ee-1.0.xsd">
        <hello/>
      </epp>
    XML
  end
end
