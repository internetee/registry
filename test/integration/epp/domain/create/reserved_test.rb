require 'test_helper'

class EppDomainCreateReservedTest < ApplicationIntegrationTest
  setup do
    @reserved_domain = reserved_domains(:one)
  end

  def test_registers_reserved_domain_with_correct_registration_code
    assert_equal 'reserved.test', @reserved_domain.name
    assert_equal 'reserved-001', @reserved_domain.registration_code

    request_xml = <<-XML
      <?xml version="1.0" encoding="UTF-8" standalone="no"?>
      <epp xmlns="https://epp.tld.ee/schema/epp-ee-1.0.xsd">
        <command>
          <create>
            <domain:create xmlns:domain="https://epp.tld.ee/schema/domain-eis-1.0.xsd">
              <domain:name>reserved.test</domain:name>
              <domain:registrant>john-001</domain:registrant>
            </domain:create>
          </create>
          <extension>
            <eis:extdata xmlns:eis="https://epp.tld.ee/schema/eis-1.0.xsd">
              <eis:legalDocument type="pdf">#{'test' * 2000}</eis:legalDocument>
              <eis:reserved>
                <eis:pw>reserved-001</eis:pw>
              </eis:reserved>
            </eis:extdata>
          </extension>
        </command>
      </epp>
    XML

    assert_difference 'Domain.count' do
      post '/epp/command/create', { frame: request_xml }, 'HTTP_COOKIE' => 'session=api_bestnames'
    end

    response_xml = Nokogiri::XML(response.body)
    assert_equal '1000', response_xml.at_css('result')[:code]
    assert_equal 1, Nokogiri::XML(response.body).css('result').size
  end

  def test_registering_reserved_domain_regenerates_registration_code
    assert_equal 'reserved.test', @reserved_domain.name
    assert_equal 'reserved-001', @reserved_domain.registration_code

    request_xml = <<-XML
      <?xml version="1.0" encoding="UTF-8" standalone="no"?>
      <epp xmlns="https://epp.tld.ee/schema/epp-ee-1.0.xsd">
        <command>
          <create>
            <domain:create xmlns:domain="https://epp.tld.ee/schema/domain-eis-1.0.xsd">
              <domain:name>reserved.test</domain:name>
              <domain:registrant>john-001</domain:registrant>
            </domain:create>
          </create>
          <extension>
            <eis:extdata xmlns:eis="https://epp.tld.ee/schema/eis-1.0.xsd">
              <eis:legalDocument type="pdf">#{'test' * 2000}</eis:legalDocument>
              <eis:reserved>
                <eis:pw>reserved-001</eis:pw>
              </eis:reserved>
            </eis:extdata>
          </extension>
        </command>
      </epp>
    XML

    post '/epp/command/create', { frame: request_xml }, 'HTTP_COOKIE' => 'session=api_bestnames'
    @reserved_domain.reload

    assert_not_equal 'reserved-001', @reserved_domain.registration_code
  end

  def test_domain_cannot_be_registered_with_wrong_registration_code
    assert_equal 'reserved.test', @reserved_domain.name
    assert_equal 'reserved-001', @reserved_domain.registration_code

    request_xml = <<-XML
      <?xml version="1.0" encoding="UTF-8" standalone="no"?>
      <epp xmlns="https://epp.tld.ee/schema/epp-ee-1.0.xsd">
        <command>
          <create>
            <domain:create xmlns:domain="https://epp.tld.ee/schema/domain-eis-1.0.xsd">
              <domain:name>reserved.test</domain:name>
              <domain:registrant>john-001</domain:registrant>
            </domain:create>
          </create>
          <extension>
            <eis:extdata xmlns:eis="https://epp.tld.ee/schema/eis-1.0.xsd">
              <eis:legalDocument type="pdf">#{'test' * 2000}</eis:legalDocument>
              <eis:reserved>
                <eis:pw>wrong</eis:pw>
              </eis:reserved>
            </eis:extdata>
          </extension>
        </command>
      </epp>
    XML

    assert_no_difference 'Domain.count' do
      post '/epp/command/create', { frame: request_xml }, 'HTTP_COOKIE' => 'session=api_bestnames'
    end

    response_xml = Nokogiri::XML(response.body)
    assert_equal '2202', response_xml.at_css('result')[:code]
    assert_equal 'Invalid authorization information; invalid reserved>pw value',
                 response_xml.at_css('result msg').text
  end

  def test_domain_cannot_be_registered_without_registration_code
    assert_equal 'reserved.test', @reserved_domain.name

    request_xml = <<-XML
      <?xml version="1.0" encoding="UTF-8" standalone="no"?>
      <epp xmlns="https://epp.tld.ee/schema/epp-ee-1.0.xsd">
        <command>
          <create>
            <domain:create xmlns:domain="https://epp.tld.ee/schema/domain-eis-1.0.xsd">
              <domain:name>reserved.test</domain:name>
              <domain:registrant>john-001</domain:registrant>
            </domain:create>
          </create>
          <extension>
            <eis:extdata xmlns:eis="https://epp.tld.ee/schema/eis-1.0.xsd">
              <eis:legalDocument type="pdf">#{'test' * 2000}</eis:legalDocument>
            </eis:extdata>
          </extension>
        </command>
      </epp>
    XML

    assert_no_difference 'Domain.count' do
      post '/epp/command/create', { frame: request_xml }, 'HTTP_COOKIE' => 'session=api_bestnames'
    end

    response_xml = Nokogiri::XML(response.body)
    assert_equal '2003', response_xml.at_css('result')[:code]
    assert_equal 'Required parameter missing; reserved>pw element required for reserved domains',
                 response_xml.at_css('result msg').text
  end
end
