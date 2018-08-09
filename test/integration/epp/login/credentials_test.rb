require 'test_helper'

class EppLoginCredentialsTest < ApplicationIntegrationTest
  def test_correct_credentials
    request_xml = <<-XML
      <?xml version="1.0" encoding="UTF-8" standalone="no"?>
      <epp xmlns="https://epp.tld.ee/schema/epp-ee-1.0.xsd">
        <command>
          <login>
            <clID>test_bestnames</clID>
            <pw>testtest</pw>
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
    assert EppSession.find_by(session_id: 'new_session_id')
    assert_equal users(:api_bestnames), EppSession.find_by(session_id: 'new_session_id').user
    assert Nokogiri::XML(response.body).at_css('result[code="1000"]')
    assert_equal 1, Nokogiri::XML(response.body).css('result').size
  end

  def test_already_logged_in
    assert true # Handled by mod_epp
  end

  def test_wrong_credentials
    request_xml = <<-XML
      <?xml version="1.0" encoding="UTF-8" standalone="no"?>
      <epp xmlns="https://epp.tld.ee/schema/epp-ee-1.0.xsd">
        <command>
          <login>
            <clID>non-existent</clID>
            <pw>valid-but-wrong</pw>
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

    post '/epp/session/login', { frame: request_xml }, { 'HTTP_COOKIE' => 'session=any_random_string' }
    assert Nokogiri::XML(response.body).at_css('result[code="2501"]')
  end
end
