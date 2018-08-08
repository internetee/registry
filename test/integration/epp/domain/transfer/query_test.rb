require 'test_helper'

class EppDomainTransferQueryTest < ApplicationIntegrationTest
  def test_returns_domain_transfer_details
    post '/epp/command/transfer', { frame: request_xml }, { 'HTTP_COOKIE' => 'session=api_bestnames' }
    xml_doc = Nokogiri::XML(response.body)
    assert_equal '1000', xml_doc.at_css('result')[:code]
    assert_equal 1, xml_doc.css('result').size
    assert_equal 'shop.test', xml_doc.xpath('//domain:name', 'domain' => 'https://epp.tld.ee/schema/domain-eis-1.0.xsd').text
    assert_equal 'serverApproved', xml_doc.xpath('//domain:trStatus', 'domain' => 'https://epp.tld.ee/schema/domain-eis-1.0.xsd').text
    assert_equal 'goodnames', xml_doc.xpath('//domain:reID', 'domain' => 'https://epp.tld.ee/schema/domain-eis-1.0.xsd').text
    assert_equal 'bestnames', xml_doc.xpath('//domain:acID', 'domain' => 'https://epp.tld.ee/schema/domain-eis-1.0.xsd').text
  end

  def test_wrong_transfer_code
    request_xml = <<-XML
      <?xml version="1.0" encoding="UTF-8" standalone="no"?>
      <epp xmlns="https://epp.tld.ee/schema/epp-ee-1.0.xsd">
        <command>
          <transfer op="query">
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

    post '/epp/command/transfer', { frame: request_xml }, { 'HTTP_COOKIE' => 'session=api_bestnames' }
    assert_equal '2201', Nokogiri::XML(response.body).at_css('result')[:code]
  end

  def test_no_domain_transfer
    domains(:shop).transfers.delete_all
    post '/epp/command/transfer', { frame: request_xml }, { 'HTTP_COOKIE' => 'session=api_bestnames' }
    assert_equal '2303', Nokogiri::XML(response.body).at_css('result')[:code]
  end

  private

  def request_xml
    <<-XML
      <?xml version="1.0" encoding="UTF-8" standalone="no"?>
      <epp xmlns="https://epp.tld.ee/schema/epp-ee-1.0.xsd">
        <command>
          <transfer op="query">
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
  end
end
