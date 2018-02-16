require 'test_helper'

class EppDomainTransferTest < ActionDispatch::IntegrationTest
  def test_successfully_transfers_domain
    request_xml = <<-XML
      <?xml version="1.0" encoding="UTF-8" standalone="no"?>
      <epp xmlns="https://epp.tld.ee/schema/epp-ee-1.0.xsd">
        <command>
          <transfer op="request">
            <domain:transfer xmlns:domain="https://epp.tld.ee/schema/domain-eis-1.0.xsd">
              <domain:name>shop.test</domain:name>
              <domain:authInfo>
                <domain:pw>65078d5</domain:pw>
              </domain:authInfo>
            </domain:transfer>
          </transfer>
        </command>
      </epp>
    XML

    session_id = epp_sessions(:api_goodnames).session_id
    post '/epp/command/transfer', { frame: request_xml }, { 'HTTP_COOKIE' => "session=#{session_id}" }
    assert_equal registrars(:goodnames), domains(:shop).registrar
    assert Nokogiri::XML(response.body).at_css('result[code="1000"]')
    assert_equal 1, Nokogiri::XML(response.body).css('result').size
  end

  def test_non_existent_domain
    request_xml = <<-XML
      <?xml version="1.0" encoding="UTF-8" standalone="no"?>
      <epp xmlns="https://epp.tld.ee/schema/epp-ee-1.0.xsd">
        <command>
          <transfer op="request">
            <domain:transfer xmlns:domain="https://epp.tld.ee/schema/domain-eis-1.0.xsd">
              <domain:name>non-existent.test</domain:name>
              <domain:authInfo>
                <domain:pw>any</domain:pw>
              </domain:authInfo>
            </domain:transfer>
          </transfer>
        </command>
      </epp>
    XML

    session_id = epp_sessions(:api_goodnames).session_id
    post '/epp/command/transfer', { frame: request_xml }, { 'HTTP_COOKIE' => "session=#{session_id}" }
    assert Nokogiri::XML(response.body).at_css('result[code="2303"]')
  end
end
