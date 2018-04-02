require 'test_helper'

class EppDomainUpdateTest < ActionDispatch::IntegrationTest
  def test_discarded_domain_cannot_be_updated
    domains(:shop).discard

    request_xml = <<-XML
      <?xml version="1.0" encoding="UTF-8" standalone="no"?>
      <epp xmlns="https://epp.tld.ee/schema/epp-ee-1.0.xsd">
        <command>
          <update>
            <domain:update xmlns:domain="https://epp.tld.ee/schema/domain-eis-1.0.xsd">
              <domain:name>shop.test</domain:name>
            </domain:update>
          </update>
        </command>
      </epp>
    XML

    post '/epp/command/update', { frame: request_xml }, 'HTTP_COOKIE' => 'session=api_bestnames'
    assert_equal '2105', Nokogiri::XML(response.body).at_css('result')[:code]
  end
end
