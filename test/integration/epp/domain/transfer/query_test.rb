require 'test_helper'

class EppDomainTransferQueryTest < EppTestCase
  def test_returns_domain_transfer_details
    post epp_transfer_path, { frame: request_xml }, { 'HTTP_COOKIE' => 'session=api_bestnames' }
    xml_doc = Nokogiri::XML(response.body)
    assert_epp_response :completed_successfully
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

    post epp_transfer_path, { frame: request_xml }, { 'HTTP_COOKIE' => 'session=api_bestnames' }

    assert_epp_response :invalid_authorization_information
  end

  def test_no_domain_transfer
    domains(:shop).transfers.delete_all
    post epp_transfer_path, { frame: request_xml }, { 'HTTP_COOKIE' => 'session=api_bestnames' }
    assert_epp_response :object_does_not_exist
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
