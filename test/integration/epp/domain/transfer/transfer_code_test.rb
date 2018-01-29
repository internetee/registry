require 'test_helper'

class EppDomainTransferTransferCodeTest < ActionDispatch::IntegrationTest
  def setup
    login_as users(:api_goodnames)
  end

  def test_wrong
    request_xml = <<-XML
      <?xml version="1.0" encoding="UTF-8" standalone="no"?>
      <epp xmlns="https://epp.tld.ee/schema/epp-ee-1.0.xsd">
        <command>
          <transfer op="request">
            <domain:transfer xmlns:domain="https://epp.tld.ee/schema/domain-eis-1.0.xsd">
              <domain:name>shop.test</domain:name>
              <domain:authInfo>
                <domain:pw>wrong</domain:pw>
              </domain:authInfo>
            </domain:transfer>
          </transfer>
        </command>
      </epp>
    XML

    session_id = epp_sessions(:api_goodnames).session_id
    post '/epp/command/transfer', { frame: request_xml }, { 'HTTP_COOKIE' => "session=#{session_id}" }
    refute_equal registrars(:goodnames), domains(:shop).registrar
    assert Nokogiri::XML(response.body).at_css('result[code="2201"]')
  end
end
