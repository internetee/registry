require 'test_helper'

class EppDomainInfoBaseTest < EppTestCase
  def test_returns_valid_response
    assert_equal 'john-001', contacts(:john).code
    domains(:shop).update_columns(statuses: [DomainStatus::OK],
                                  created_at: Time.zone.parse('2010-07-05'),
                                  updated_at: Time.zone.parse('2010-07-06'),
                                  valid_to: Time.zone.parse('2010-07-07'))

    request_xml = <<-XML
      <?xml version="1.0" encoding="UTF-8" standalone="no"?>
      <epp xmlns="https://epp.tld.ee/schema/epp-ee-1.0.xsd">
        <command>
          <info>
            <domain:info xmlns:domain="https://epp.tld.ee/schema/domain-eis-1.0.xsd">
              <domain:name>shop.test</domain:name>
            </domain:info>
          </info>
        </command>
      </epp>
    XML

    post epp_info_path, { frame: request_xml }, 'HTTP_COOKIE' => 'session=api_bestnames'

    response_xml = Nokogiri::XML(response.body)
    assert_epp_response :completed_successfully
    assert_equal 'shop.test', response_xml.at_xpath('//domain:name', 'domain' => 'https://epp.tld.ee/schema/domain-eis-1.0.xsd').text
    assert_equal 'ok', response_xml.at_xpath('//domain:status', 'domain' => 'https://epp.tld.ee/schema/domain-eis-1.0.xsd')['s']
    assert_equal 'john-001', response_xml.at_xpath('//domain:registrant', 'domain' => 'https://epp.tld.ee/schema/domain-eis-1.0.xsd').text
    assert_equal '2010-07-05T00:00:00+03:00', response_xml.at_xpath('//domain:crDate', 'domain' => 'https://epp.tld.ee/schema/domain-eis-1.0.xsd').text
    assert_equal '2010-07-06T00:00:00+03:00', response_xml.at_xpath('//domain:upDate', 'domain' => 'https://epp.tld.ee/schema/domain-eis-1.0.xsd').text
    assert_equal '2010-07-07T00:00:00+03:00', response_xml.at_xpath('//domain:exDate', 'domain' => 'https://epp.tld.ee/schema/domain-eis-1.0.xsd').text
  end

  def test_reveals_transfer_code_when_domain_is_owned_by_current_user
    assert_equal '65078d5', domains(:shop).transfer_code

    request_xml = <<-XML
      <?xml version="1.0" encoding="UTF-8" standalone="no"?>
      <epp xmlns="https://epp.tld.ee/schema/epp-ee-1.0.xsd">
        <command>
          <info>
            <domain:info xmlns:domain="https://epp.tld.ee/schema/domain-eis-1.0.xsd">
              <domain:name>shop.test</domain:name>
            </domain:info>
          </info>
        </command>
      </epp>
    XML

    post epp_info_path, { frame: request_xml }, 'HTTP_COOKIE' => 'session=api_bestnames'

    response_xml = Nokogiri::XML(response.body)
    assert_equal '65078d5', response_xml.at_xpath('//domain:authInfo/domain:pw', 'domain' => 'https://epp.tld.ee/schema/domain-eis-1.0.xsd').text
  end

  # Transfer code is the only info we conceal from other registrars, hence a bit oddly-looking
  # test name
  def test_reveals_transfer_code_when_domain_is_not_owned_by_current_user_and_transfer_code_is_provided
    assert_equal '65078d5', domains(:shop).transfer_code

    request_xml = <<-XML
      <?xml version="1.0" encoding="UTF-8" standalone="no"?>
      <epp xmlns="https://epp.tld.ee/schema/epp-ee-1.0.xsd">
        <command>
          <info>
            <domain:info xmlns:domain="https://epp.tld.ee/schema/domain-eis-1.0.xsd">
              <domain:name>shop.test</domain:name>
              <domain:authInfo>
                <domain:pw>65078d5</domain:pw>
              </domain:authInfo>
            </domain:info>
          </info>
        </command>
      </epp>
    XML

    post epp_info_path, { frame: request_xml }, 'HTTP_COOKIE' => 'session=api_goodnames'

    response_xml = Nokogiri::XML(response.body)
    assert_equal '65078d5', response_xml.at_xpath('//domain:authInfo/domain:pw', 'domain' => 'https://epp.tld.ee/schema/domain-eis-1.0.xsd').text
  end

  def test_conceals_transfer_code_when_domain_is_not_owned_by_current_user
    request_xml = <<-XML
      <?xml version="1.0" encoding="UTF-8" standalone="no"?>
      <epp xmlns="https://epp.tld.ee/schema/epp-ee-1.0.xsd">
        <command>
          <info>
            <domain:info xmlns:domain="https://epp.tld.ee/schema/domain-eis-1.0.xsd">
              <domain:name>shop.test</domain:name>
              <domain:authInfo>
                <domain:pw></domain:pw>
              </domain:authInfo>
            </domain:info>
          </info>
        </command>
      </epp>
    XML

    post epp_info_path, { frame: request_xml }, 'HTTP_COOKIE' => 'session=api_goodnames'

    response_xml = Nokogiri::XML(response.body)
    assert_nil response_xml.at_xpath('//domain:authInfo/domain:pw',
                                     'domain' => 'https://epp.tld.ee/schema/domain-eis-1.0.xsd')
  end
end