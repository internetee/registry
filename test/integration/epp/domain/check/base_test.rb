require 'test_helper'

class EppDomainCheckBaseTest < EppTestCase
  def test_returns_valid_response
    request_xml = <<-XML
      <?xml version="1.0" encoding="UTF-8" standalone="no"?>
      <epp xmlns="#{Xsd::Schema.filename(for_prefix: 'epp-ee')}">
        <command>
          <check>
            <domain:check xmlns:domain="#{Xsd::Schema.filename(for_prefix: 'domain-ee')}">
              <domain:name>some.test</domain:name>
            </domain:check>
          </check>
        </command>
      </epp>
    XML

    post epp_check_path, params: { frame: request_xml },
         headers: { 'HTTP_COOKIE' => 'session=api_bestnames' }

    response_xml = Nokogiri::XML(response.body)
    assert_epp_response :completed_successfully
    assert_correct_against_schema response_xml
    assert_equal 'some.test', response_xml.at_xpath('//domain:name', 'domain' => "#{Xsd::Schema.filename(for_prefix: 'domain-ee')}").text
  end

  def test_domain_is_available_when_not_registered_or_blocked
    request_xml = <<-XML
      <?xml version="1.0" encoding="UTF-8" standalone="no"?>
      <epp xmlns="#{Xsd::Schema.filename(for_prefix: 'epp-ee')}">
        <command>
          <check>
            <domain:check xmlns:domain="#{Xsd::Schema.filename(for_prefix: 'domain-ee')}">
              <domain:name>available.test</domain:name>
            </domain:check>
          </check>
        </command>
      </epp>
    XML

    post epp_check_path, params: { frame: request_xml },
         headers: { 'HTTP_COOKIE' => 'session=api_bestnames' }

    response_xml = Nokogiri::XML(response.body)
    assert_correct_against_schema response_xml
    assert_equal '1', response_xml.at_xpath('//domain:name', 'domain' => "#{Xsd::Schema.filename(for_prefix: 'domain-ee')}")['avail']
    assert_nil response_xml.at_xpath('//domain:reason', 'domain' => "#{Xsd::Schema.filename(for_prefix: 'domain-ee')}")
  end

  def test_domain_is_available_when_reserved
    assert_equal 'reserved.test', reserved_domains(:one).name

    request_xml = <<-XML
      <?xml version="1.0" encoding="UTF-8" standalone="no"?>
      <epp xmlns="#{Xsd::Schema.filename(for_prefix: 'epp-ee')}">
        <command>
          <check>
            <domain:check xmlns:domain="#{Xsd::Schema.filename(for_prefix: 'domain-ee')}">
              <domain:name>reserved.test</domain:name>
            </domain:check>
          </check>
        </command>
      </epp>
    XML

    post epp_check_path, params: { frame: request_xml },
         headers: { 'HTTP_COOKIE' => 'session=api_bestnames' }

    response_xml = Nokogiri::XML(response.body)
    assert_correct_against_schema response_xml
    assert_equal '1', response_xml.at_xpath('//domain:name', 'domain' => "#{Xsd::Schema.filename(for_prefix: 'domain-ee')}")['avail']
    assert_nil response_xml.at_xpath('//domain:reason', 'domain' => "#{Xsd::Schema.filename(for_prefix: 'domain-ee')}")
  end

  def test_domain_is_unavailable_when_format_is_invalid
    request_xml = <<-XML
      <?xml version="1.0" encoding="UTF-8" standalone="no"?>
      <epp xmlns="#{Xsd::Schema.filename(for_prefix: 'epp-ee')}">
        <command>
          <check>
            <domain:check xmlns:domain="#{Xsd::Schema.filename(for_prefix: 'domain-ee')}">
              <domain:name>invalid</domain:name>
            </domain:check>
          </check>
        </command>
      </epp>
    XML

    post epp_check_path, params: { frame: request_xml },
         headers: { 'HTTP_COOKIE' => 'session=api_bestnames' }

    response_xml = Nokogiri::XML(response.body)
    assert_correct_against_schema response_xml
    assert_equal '0', response_xml.at_xpath('//domain:name', 'domain' => "#{Xsd::Schema.filename(for_prefix: 'domain-ee')}")['avail']
    assert_equal 'invalid format', response_xml.at_xpath('//domain:reason', 'domain' => "#{Xsd::Schema.filename(for_prefix: 'domain-ee')}").text
  end

  def test_domain_is_unavailable_when_registered
    assert_equal 'shop.test', domains(:shop).name

    request_xml = <<-XML
      <?xml version="1.0" encoding="UTF-8" standalone="no"?>
      <epp xmlns="#{Xsd::Schema.filename(for_prefix: 'epp-ee')}">
        <command>
          <check>
            <domain:check xmlns:domain="#{Xsd::Schema.filename(for_prefix: 'domain-ee')}">
              <domain:name>shop.test</domain:name>
            </domain:check>
          </check>
        </command>
      </epp>
    XML

    post epp_check_path, params: { frame: request_xml },
         headers: { 'HTTP_COOKIE' => 'session=api_bestnames' }

    response_xml = Nokogiri::XML(response.body)
    assert_correct_against_schema response_xml
    assert_equal '0', response_xml.at_xpath('//domain:name', 'domain' => "#{Xsd::Schema.filename(for_prefix: 'domain-ee')}")['avail']
    assert_equal 'in use', response_xml.at_xpath('//domain:reason', 'domain' => "#{Xsd::Schema.filename(for_prefix: 'domain-ee')}").text
  end

  def test_domain_is_unavailable_when_blocked
    assert_equal 'blocked.test', blocked_domains(:one).name

    request_xml = <<-XML
      <?xml version="1.0" encoding="UTF-8" standalone="no"?>
      <epp xmlns="#{Xsd::Schema.filename(for_prefix: 'epp-ee')}">
        <command>
          <check>
            <domain:check xmlns:domain="#{Xsd::Schema.filename(for_prefix: 'domain-ee')}">
              <domain:name>blocked.test</domain:name>
            </domain:check>
          </check>
        </command>
      </epp>
    XML

    post epp_check_path, params: { frame: request_xml },
         headers: { 'HTTP_COOKIE' => 'session=api_bestnames' }

    response_xml = Nokogiri::XML(response.body)
    assert_correct_against_schema response_xml
    assert_equal '0', response_xml.at_xpath('//domain:name', 'domain' => "#{Xsd::Schema.filename(for_prefix: 'domain-ee')}")['avail']
    assert_equal 'Blocked', response_xml.at_xpath('//domain:reason', 'domain' => "#{Xsd::Schema.filename(for_prefix: 'domain-ee')}").text
  end

  def test_domain_is_unavailable_when_zone_with_the_same_origin_exists
    assert_equal 'test', dns_zones(:one).origin

    request_xml = <<-XML
      <?xml version="1.0" encoding="UTF-8" standalone="no"?>
      <epp xmlns="#{Xsd::Schema.filename(for_prefix: 'epp-ee')}">
        <command>
          <check>
            <domain:check xmlns:domain="#{Xsd::Schema.filename(for_prefix: 'domain-ee')}">
              <domain:name>test</domain:name>
            </domain:check>
          </check>
        </command>
      </epp>
    XML

    post epp_check_path, params: { frame: request_xml },
         headers: { 'HTTP_COOKIE' => 'session=api_bestnames' }

    response_xml = Nokogiri::XML(response.body)
    assert_correct_against_schema response_xml
    assert_equal '0', response_xml.at_xpath('//domain:name', 'domain' => "#{Xsd::Schema.filename(for_prefix: 'domain-ee')}")['avail']
    assert_equal 'Zone with the same origin exists', response_xml.at_xpath('//domain:reason', 'domain' => "#{Xsd::Schema.filename(for_prefix: 'domain-ee')}").text
  end

  def test_multiple_domains
    request_xml = <<-XML
      <?xml version="1.0" encoding="UTF-8" standalone="no"?>
      <epp xmlns="#{Xsd::Schema.filename(for_prefix: 'epp-ee')}">
        <command>
          <check>
            <domain:check xmlns:domain="#{Xsd::Schema.filename(for_prefix: 'domain-ee')}">
              <domain:name>one.test</domain:name>
              <domain:name>two.test</domain:name>
              <domain:name>three.test</domain:name>
            </domain:check>
          </check>
        </command>
      </epp>
    XML

    post epp_check_path, params: { frame: request_xml },
         headers: { 'HTTP_COOKIE' => 'session=api_bestnames' }

    response_xml = Nokogiri::XML(response.body)
    assert_correct_against_schema response_xml
    assert_equal 3, response_xml.xpath('//domain:cd', 'domain' => "#{Xsd::Schema.filename(for_prefix: 'domain-ee')}").size
  end
end
