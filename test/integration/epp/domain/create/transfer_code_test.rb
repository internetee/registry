require 'test_helper'

class EppDomainCreateTransferCodeTest < ActionDispatch::IntegrationTest
  def setup
    travel_to Time.zone.parse('2010-07-05')
    login_as users(:api_bestnames)
  end

  def test_generates_default
    request_xml = <<-XML
      <?xml version="1.0" encoding="UTF-8" standalone="no"?>
      <epp xmlns="https://epp.tld.ee/schema/epp-ee-1.0.xsd">
        <command>
          <create>
            <domain:create xmlns:domain="https://epp.tld.ee/schema/domain-eis-1.0.xsd">
              <domain:name>brandnew.test</domain:name>
              <domain:period unit="y">1</domain:period>
              <domain:registrant>john-001</domain:registrant>
            </domain:create>
          </create>
          <extension>
            <eis:extdata xmlns:eis="https://epp.tld.ee/schema/eis-1.0.xsd">
              <eis:legalDocument type="pdf">#{'test' * 2000}</eis:legalDocument>
            </eis:extdata>
          </extension>
        </command>
      </epp>
    XML

    session_id = epp_sessions(:api_bestnames).session_id
    post '/epp/command/create', { frame: request_xml }, { 'HTTP_COOKIE' => "session=#{session_id}" }
    refute_empty Domain.find_by(name: 'brandnew.test').transfer_code
  end

  def test_honors_custom
    request_xml = <<-XML
      <?xml version="1.0" encoding="UTF-8" standalone="no"?>
      <epp xmlns="https://epp.tld.ee/schema/epp-ee-1.0.xsd">
        <command>
          <create>
            <domain:create xmlns:domain="https://epp.tld.ee/schema/domain-eis-1.0.xsd">
              <domain:name>brandnew.test</domain:name>
              <domain:period unit="y">1</domain:period>
              <domain:registrant>john-001</domain:registrant>
              <domain:authInfo>
                <domain:pw>1058ad73</domain:pw>
              </domain:authInfo>
            </domain:create>
          </create>
          <extension>
            <eis:extdata xmlns:eis="https://epp.tld.ee/schema/eis-1.0.xsd">
              <eis:legalDocument type="pdf">#{'test' * 2000}</eis:legalDocument>
            </eis:extdata>
          </extension>
        </command>
      </epp>
    XML

    session_id = epp_sessions(:api_bestnames).session_id
    post '/epp/command/create', { frame: request_xml }, { 'HTTP_COOKIE' => "session=#{session_id}" }
    assert_equal '1058ad73', Domain.find_by(name: 'brandnew.test').transfer_code
  end
end
