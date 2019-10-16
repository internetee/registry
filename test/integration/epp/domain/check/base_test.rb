require 'test_helper'

class EppDomainCheckBaseTest < EppTestCase
  def test_returns_valid_response
    request_xml = <<-XML
      <?xml version="1.0" encoding="UTF-8" standalone="no"?>
      <epp xmlns="https://epp.tld.ee/schema/epp-ee-1.0.xsd">
        <command>
          <check>
            <domain:check xmlns:domain="https://epp.tld.ee/schema/domain-eis-1.0.xsd">
              <domain:name>some.test</domain:name>
            </domain:check>
          </check>
        </command>
      </epp>
    XML

    post epp_check_path, { frame: request_xml }, 'HTTP_COOKIE' => 'session=api_bestnames'

    response_xml = Nokogiri::XML(response.body)
    assert_epp_response :completed_successfully
    assert_equal 'some.test', response_xml.at_xpath('//domain:name', 'domain' => 'https://epp.tld.ee/schema/domain-eis-1.0.xsd').text
  end

  def test_domain_is_available_when_not_registered_or_blocked
    request_xml = <<-XML
      <?xml version="1.0" encoding="UTF-8" standalone="no"?>
      <epp xmlns="https://epp.tld.ee/schema/epp-ee-1.0.xsd">
        <command>
          <check>
            <domain:check xmlns:domain="https://epp.tld.ee/schema/domain-eis-1.0.xsd">
              <domain:name>available.test</domain:name>
            </domain:check>
          </check>
        </command>
      </epp>
    XML

    post epp_check_path, { frame: request_xml }, 'HTTP_COOKIE' => 'session=api_bestnames'

    response_xml = Nokogiri::XML(response.body)
    assert_equal '1', response_xml.at_xpath('//domain:name', 'domain' => 'https://epp.tld.ee/schema/domain-eis-1.0.xsd')['avail']
    assert_nil response_xml.at_xpath('//domain:reason', 'domain' => 'https://epp.tld.ee/schema/domain-eis-1.0.xsd')
  end

  def test_domain_is_available_when_reserved
    assert_equal 'reserved.test', reserved_domains(:one).name

    request_xml = <<-XML
      <?xml version="1.0" encoding="UTF-8" standalone="no"?>
      <epp xmlns="https://epp.tld.ee/schema/epp-ee-1.0.xsd">
        <command>
          <check>
            <domain:check xmlns:domain="https://epp.tld.ee/schema/domain-eis-1.0.xsd">
              <domain:name>reserved.test</domain:name>
            </domain:check>
          </check>
        </command>
      </epp>
    XML

    post epp_check_path, { frame: request_xml }, 'HTTP_COOKIE' => 'session=api_bestnames'

    response_xml = Nokogiri::XML(response.body)
    assert_equal '1', response_xml.at_xpath('//domain:name', 'domain' => 'https://epp.tld.ee/schema/domain-eis-1.0.xsd')['avail']
    assert_nil response_xml.at_xpath('//domain:reason', 'domain' => 'https://epp.tld.ee/schema/domain-eis-1.0.xsd')
  end

  def test_domain_is_unavailable_when_format_is_invalid
    request_xml = <<-XML
      <?xml version="1.0" encoding="UTF-8" standalone="no"?>
      <epp xmlns="https://epp.tld.ee/schema/epp-ee-1.0.xsd">
        <command>
          <check>
            <domain:check xmlns:domain="https://epp.tld.ee/schema/domain-eis-1.0.xsd">
              <domain:name>invalid</domain:name>
            </domain:check>
          </check>
        </command>
      </epp>
    XML

    post epp_check_path, { frame: request_xml }, 'HTTP_COOKIE' => 'session=api_bestnames'

    response_xml = Nokogiri::XML(response.body)
    assert_equal '0', response_xml.at_xpath('//domain:name', 'domain' => 'https://epp.tld.ee/schema/domain-eis-1.0.xsd')['avail']
    assert_equal 'invalid format', response_xml.at_xpath('//domain:reason', 'domain' => 'https://epp.tld.ee/schema/domain-eis-1.0.xsd').text
  end

  def test_domain_is_unavailable_when_registered
    assert_equal 'shop.test', domains(:shop).name

    request_xml = <<-XML
      <?xml version="1.0" encoding="UTF-8" standalone="no"?>
      <epp xmlns="https://epp.tld.ee/schema/epp-ee-1.0.xsd">
        <command>
          <check>
            <domain:check xmlns:domain="https://epp.tld.ee/schema/domain-eis-1.0.xsd">
              <domain:name>shop.test</domain:name>
            </domain:check>
          </check>
        </command>
      </epp>
    XML

    post epp_check_path, { frame: request_xml }, 'HTTP_COOKIE' => 'session=api_bestnames'

    response_xml = Nokogiri::XML(response.body)
    assert_equal '0', response_xml.at_xpath('//domain:name', 'domain' => 'https://epp.tld.ee/schema/domain-eis-1.0.xsd')['avail']
    assert_equal 'in use', response_xml.at_xpath('//domain:reason', 'domain' => 'https://epp.tld.ee/schema/domain-eis-1.0.xsd').text
  end

  def test_domain_is_unavailable_when_blocked
    assert_equal 'blocked.test', blocked_domains(:one).name

    request_xml = <<-XML
      <?xml version="1.0" encoding="UTF-8" standalone="no"?>
      <epp xmlns="https://epp.tld.ee/schema/epp-ee-1.0.xsd">
        <command>
          <check>
            <domain:check xmlns:domain="https://epp.tld.ee/schema/domain-eis-1.0.xsd">
              <domain:name>blocked.test</domain:name>
            </domain:check>
          </check>
        </command>
      </epp>
    XML

    post epp_check_path, { frame: request_xml }, 'HTTP_COOKIE' => 'session=api_bestnames'

    response_xml = Nokogiri::XML(response.body)
    assert_equal '0', response_xml.at_xpath('//domain:name', 'domain' => 'https://epp.tld.ee/schema/domain-eis-1.0.xsd')['avail']
    assert_equal 'Blocked', response_xml.at_xpath('//domain:reason', 'domain' => 'https://epp.tld.ee/schema/domain-eis-1.0.xsd').text
  end

  def test_domain_is_unavailable_when_zone_with_the_same_origin_exists
    assert_equal 'test', dns_zones(:one).origin

    request_xml = <<-XML
      <?xml version="1.0" encoding="UTF-8" standalone="no"?>
      <epp xmlns="https://epp.tld.ee/schema/epp-ee-1.0.xsd">
        <command>
          <check>
            <domain:check xmlns:domain="https://epp.tld.ee/schema/domain-eis-1.0.xsd">
              <domain:name>test</domain:name>
            </domain:check>
          </check>
        </command>
      </epp>
    XML

    post epp_check_path, { frame: request_xml }, 'HTTP_COOKIE' => 'session=api_bestnames'

    response_xml = Nokogiri::XML(response.body)
    assert_equal '0', response_xml.at_xpath('//domain:name', 'domain' => 'https://epp.tld.ee/schema/domain-eis-1.0.xsd')['avail']
    assert_equal 'Zone with the same origin exists', response_xml.at_xpath('//domain:reason', 'domain' => 'https://epp.tld.ee/schema/domain-eis-1.0.xsd').text
  end

  def test_multiple_domains
    request_xml = <<-XML
      <?xml version="1.0" encoding="UTF-8" standalone="no"?>
      <epp xmlns="https://epp.tld.ee/schema/epp-ee-1.0.xsd">
        <command>
          <check>
            <domain:check xmlns:domain="https://epp.tld.ee/schema/domain-eis-1.0.xsd">
              <domain:name>one.test</domain:name>
              <domain:name>two.test</domain:name>
              <domain:name>three.test</domain:name>
            </domain:check>
          </check>
        </command>
      </epp>
    XML

    post epp_check_path, { frame: request_xml }, 'HTTP_COOKIE' => 'session=api_bestnames'

    response_xml = Nokogiri::XML(response.body)
    assert_equal 3, response_xml.xpath('//domain:cd', 'domain' => 'https://epp.tld.ee/schema/domain-eis-1.0.xsd').size
  end
end
