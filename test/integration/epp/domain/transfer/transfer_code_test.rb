require 'test_helper'

class EppDomainTransferTransferCodeTest < ActionDispatch::IntegrationTest
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

    post '/epp/command/transfer', { frame: request_xml }, { 'HTTP_COOKIE' => 'session=api_goodnames' }
    refute_equal registrars(:goodnames), domains(:shop).registrar
    assert_equal '2201', Nokogiri::XML(response.body).at_css('result')[:code]
  end
end
