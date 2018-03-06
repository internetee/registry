require 'test_helper'

class EppDomainCreateNameserversTest < ActionDispatch::IntegrationTest
  # Glue record requirement
  def test_nameserver_ip_address_is_required_if_hostname_is_under_the_same_domain
    request_xml = <<-XML
      <?xml version="1.0" encoding="UTF-8" standalone="no"?>
      <epp xmlns="https://epp.tld.ee/schema/epp-ee-1.0.xsd">
        <command>
          <create>
            <domain:create xmlns:domain="https://epp.tld.ee/schema/domain-eis-1.0.xsd">
              <domain:name>new.test</domain:name>
              <domain:ns>
                <domain:hostAttr>
                  <domain:hostName>ns1.new.test</domain:hostName>
                </domain:hostAttr>
              </domain:ns>
              <domain:registrant>john-001</domain:registrant>
            </domain:create>
          </create>
          <extension>
            <eis:extdata xmlns:eis="https://epp.tld.ee/schema/eis-1.0.xsd">
              <eis:legalDocument type="pdf">test</eis:legalDocument>
            </eis:extdata>
          </extension>
        </command>
      </epp>
    XML

    assert_no_difference 'Domain.count' do
      post '/epp/command/create', { frame: request_xml }, { 'HTTP_COOKIE' => 'session=api_bestnames' }
    end
    assert_equal '2003', Nokogiri::XML(response.body).at_css('result')[:code]
  end
end
