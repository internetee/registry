require 'test_helper'

class EppContactCheckBaseTest < EppTestCase
  setup do
    @contact = contacts(:john)
  end

  def test_returns_valid_response
    assert_equal 'john-001', @contact.code

    request_xml = <<-XML
      <?xml version="1.0" encoding="UTF-8" standalone="no"?>
      <epp xmlns="https://epp.tld.ee/schema/epp-ee-1.0.xsd">
        <command>
          <check>
            <contact:check xmlns:contact="https://epp.tld.ee/schema/contact-ee-1.1.xsd">
              <contact:id>john-001</contact:id>
            </contact:check>
          </check>
        </command>
      </epp>
    XML

    post '/epp/command/check', { frame: request_xml }, 'HTTP_COOKIE' => 'session=api_bestnames'

    response_xml = Nokogiri::XML(response.body)
    assert_epp_response :completed_successfully
    assert_equal 'john-001', response_xml.at_xpath('//contact:id', contact: xml_schema).text
  end

  def test_contact_is_available
    request_xml = <<-XML
      <?xml version="1.0" encoding="UTF-8" standalone="no"?>
      <epp xmlns="https://epp.tld.ee/schema/epp-ee-1.0.xsd">
        <command>
          <check>
            <contact:check xmlns:contact="https://epp.tld.ee/schema/contact-ee-1.1.xsd">
              <contact:id>non-existing-id</contact:id>
            </contact:check>
          </check>
        </command>
      </epp>
    XML

    post '/epp/command/check', { frame: request_xml }, 'HTTP_COOKIE' => 'session=api_bestnames'

    response_xml = Nokogiri::XML(response.body)
    assert_equal '1', response_xml.at_xpath('//contact:id', contact: xml_schema)['avail']
    assert_nil response_xml.at_xpath('//contact:reason', contact: xml_schema)
  end

  def test_contact_is_unavailable
    assert_equal 'john-001', @contact.code

    request_xml = <<-XML
      <?xml version="1.0" encoding="UTF-8" standalone="no"?>
      <epp xmlns="https://epp.tld.ee/schema/epp-ee-1.0.xsd">
        <command>
          <check>
            <contact:check xmlns:contact="https://epp.tld.ee/schema/contact-ee-1.1.xsd">
              <contact:id>john-001</contact:id>
            </contact:check>
          </check>
        </command>
      </epp>
    XML

    post '/epp/command/check', { frame: request_xml }, 'HTTP_COOKIE' => 'session=api_bestnames'

    response_xml = Nokogiri::XML(response.body)
    assert_equal '0', response_xml.at_xpath('//contact:id', contact: xml_schema)['avail']
    assert_equal 'in use', response_xml.at_xpath('//contact:reason', contact: xml_schema).text
  end

  def test_multiple_contacts
    request_xml = <<-XML
      <?xml version="1.0" encoding="UTF-8" standalone="no"?>
      <epp xmlns="https://epp.tld.ee/schema/epp-ee-1.0.xsd">
        <command>
          <check>
            <contact:check xmlns:contact="https://epp.tld.ee/schema/contact-ee-1.1.xsd">
              <contact:id>one.test</contact:id>
              <contact:id>two.test</contact:id>
              <contact:id>three.test</contact:id>
            </contact:check>
          </check>
        </command>
      </epp>
    XML

    post '/epp/command/check', { frame: request_xml }, 'HTTP_COOKIE' => 'session=api_bestnames'

    response_xml = Nokogiri::XML(response.body)
    assert_equal 3, response_xml.xpath('//contact:cd', contact: xml_schema).size
  end

  private

  def xml_schema
    'https://epp.tld.ee/schema/contact-ee-1.1.xsd'
  end
end