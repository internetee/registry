require 'test_helper'

class EppDomainCheckBaseTest < ApplicationIntegrationTest
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

    post '/epp/command/check', { frame: request_xml }, 'HTTP_COOKIE' => 'session=api_bestnames'

    response_xml = Nokogiri::XML(response.body)
    assert_equal '1000', response_xml.at_css('result')[:code]
    assert_equal 1, response_xml.css('result').size
    assert_equal 'some.test', response_xml.at_xpath('//domain:name', 'domain' => 'https://epp.tld.ee/schema/domain-eis-1.0.xsd').text
  end

  def test_domain_is_available_when_not_registered_blocked_nor_reserved
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

    post '/epp/command/check', { frame: request_xml }, 'HTTP_COOKIE' => 'session=api_bestnames'

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

    post '/epp/command/check', { frame: request_xml }, 'HTTP_COOKIE' => 'session=api_bestnames'

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

    post '/epp/command/check', { frame: request_xml }, 'HTTP_COOKIE' => 'session=api_bestnames'

    response_xml = Nokogiri::XML(response.body)
    assert_equal '0', response_xml.at_xpath('//domain:name', 'domain' => 'https://epp.tld.ee/schema/domain-eis-1.0.xsd')['avail']
    assert_equal 'in use', response_xml.at_xpath('//domain:reason', 'domain' => 'https://epp.tld.ee/schema/domain-eis-1.0.xsd').text
  end

  def test_domain_is_unavailable_when_reserved
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

    post '/epp/command/check', { frame: request_xml }, 'HTTP_COOKIE' => 'session=api_bestnames'

    response_xml = Nokogiri::XML(response.body)
    assert_equal '0', response_xml.at_xpath('//domain:name', 'domain' => 'https://epp.tld.ee/schema/domain-eis-1.0.xsd')['avail']
    assert_equal 'Domain name is reserved', response_xml.at_xpath('//domain:reason', 'domain' => 'https://epp.tld.ee/schema/domain-eis-1.0.xsd').text
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

    post '/epp/command/check', { frame: request_xml }, 'HTTP_COOKIE' => 'session=api_bestnames'

    response_xml = Nokogiri::XML(response.body)
    assert_equal 3, response_xml.xpath('//domain:cd', 'domain' => 'https://epp.tld.ee/schema/domain-eis-1.0.xsd').size
  end
end
