require 'test_helper'

class EppLoginPasswordChangeTest < ActionDispatch::IntegrationTest
  def test_password_change
    request_xml = <<-XML
      <?xml version="1.0" encoding="UTF-8" standalone="no"?>
      <epp xmlns="https://epp.tld.ee/schema/epp-ee-1.0.xsd">
        <command>
          <login>
            <clID>test_bestnames</clID>
            <pw>testtest</pw>
            <newPW>new-password</newPW>
            <options>
              <version>1.0</version>
              <lang>en</lang>
            </options>
            <svcs>
              <objURI>https://epp.tld.ee/schema/domain-eis-1.0.xsd</objURI>
              <objURI>https://epp.tld.ee/schema/contact-ee-1.1.xsd</objURI>
              <objURI>urn:ietf:params:xml:ns:host-1.0</objURI>
              <objURI>urn:ietf:params:xml:ns:keyrelay-1.0</objURI>
            </svcs>
          </login>
        </command>
      </epp>
    XML

    post '/epp/session/login', { frame: request_xml }, { 'HTTP_COOKIE' => 'session=new_session_id' }
    assert_equal 'new-password', users(:api_bestnames).plain_text_password
    assert_equal '1000', Nokogiri::XML(response.body).at_css('result')[:code]
    assert_equal 1, Nokogiri::XML(response.body).css('result').size
  end
end