require 'test_helper'

class EppContactCheckBaseTest < EppTestCase
  setup do
    @contact = contacts(:john)
  end

  def test_returns_valid_response
    assert_equal 'john-001', @contact.code

    request_xml = <<-XML
      <?xml version="1.0" encoding="UTF-8" standalone="no"?>
      <epp xmlns="#{Xsd::Schema.filename(for_prefix: 'epp-ee')}">
        <command>
          <check>
            <contact:check xmlns:contact="#{Xsd::Schema.filename(for_prefix: 'contact-ee')}">
              <contact:id>john-001</contact:id>
            </contact:check>
          </check>
        </command>
      </epp>
    XML

    post epp_check_path, params: { frame: request_xml },
         headers: { 'HTTP_COOKIE' => 'session=api_bestnames' }

    response_xml = Nokogiri::XML(response.body)
    assert_correct_against_schema response_xml
    assert_epp_response :completed_successfully
    assert_equal "#{@contact.registrar.code}:JOHN-001".upcase, response_xml.at_xpath('//contact:id', contact: xml_schema).text
  end

  def test_contact_is_available
    request_xml = <<-XML
      <?xml version="1.0" encoding="UTF-8" standalone="no"?>
      <epp xmlns="#{Xsd::Schema.filename(for_prefix: 'epp-ee')}">
        <command>
          <check>
            <contact:check xmlns:contact="#{Xsd::Schema.filename(for_prefix: 'contact-ee')}">
              <contact:id>non-existing-id</contact:id>
            </contact:check>
          </check>
        </command>
      </epp>
    XML

    post epp_check_path, params: { frame: request_xml },
         headers: { 'HTTP_COOKIE' => 'session=api_bestnames' }

    response_xml = Nokogiri::XML(response.body)
    assert_correct_against_schema response_xml
    assert_equal '1', response_xml.at_xpath('//contact:id', contact: xml_schema)['avail']
    assert_nil response_xml.at_xpath('//contact:reason', contact: xml_schema)
  end

  def test_contact_is_unavailable
    @contact.update_columns(code: "#{@contact.registrar.code}:JOHN-001".upcase)
    assert @contact.code, "#{@contact.registrar.code}:JOHN-001".upcase

    request_xml = <<-XML
      <?xml version="1.0" encoding="UTF-8" standalone="no"?>
      <epp xmlns="#{Xsd::Schema.filename(for_prefix: 'epp-ee')}">
        <command>
          <check>
            <contact:check xmlns:contact="#{Xsd::Schema.filename(for_prefix: 'contact-ee')}">
              <contact:id>john-001</contact:id>
            </contact:check>
          </check>
        </command>
      </epp>
    XML

    post epp_check_path, params: { frame: request_xml },
         headers: { 'HTTP_COOKIE' => 'session=api_bestnames' }

    response_xml = Nokogiri::XML(response.body)
    assert_correct_against_schema response_xml
    assert_equal '0', response_xml.at_xpath('//contact:id', contact: xml_schema)['avail']
    assert_equal 'in use', response_xml.at_xpath('//contact:reason', contact: xml_schema).text
  end

  def test_multiple_contacts
    request_xml = <<-XML
      <?xml version="1.0" encoding="UTF-8" standalone="no"?>
      <epp xmlns="#{Xsd::Schema.filename(for_prefix: 'epp-ee')}">
        <command>
          <check>
            <contact:check xmlns:contact="#{Xsd::Schema.filename(for_prefix: 'contact-ee')}">
              <contact:id>one.test</contact:id>
              <contact:id>two.test</contact:id>
              <contact:id>three.test</contact:id>
            </contact:check>
          </check>
        </command>
      </epp>
    XML

    post epp_check_path, params: { frame: request_xml },
         headers: { 'HTTP_COOKIE' => 'session=api_bestnames' }

    response_xml = Nokogiri::XML(response.body)
    assert_correct_against_schema response_xml
    assert_equal 3, response_xml.xpath('//contact:cd', contact: xml_schema).size
  end

  def test_check_contact_with_prefix
    @contact.update_columns(code: "#{@contact.registrar.code}:JOHN-001".upcase)
    assert @contact.code, "#{@contact.registrar.code}:JOHN-001".upcase

    request_xml = <<-XML
      <?xml version="1.0" encoding="UTF-8" standalone="no"?>
      <epp xmlns="#{Xsd::Schema.filename(for_prefix: 'epp-ee')}">
        <command>
          <check>
            <contact:check xmlns:contact="#{Xsd::Schema.filename(for_prefix: 'contact-ee')}">
              <contact:id>BESTNAMES:JOHN-001</contact:id>
            </contact:check>
          </check>
        </command>
      </epp>
    XML

    post epp_check_path, params: { frame: request_xml },
         headers: { 'HTTP_COOKIE' => 'session=api_bestnames' }

    response_xml = Nokogiri::XML(response.body)
    assert_correct_against_schema response_xml
    assert_epp_response :completed_successfully
    assert_equal "#{@contact.registrar.code}:JOHN-001".upcase, response_xml.at_xpath('//contact:id', contact: xml_schema).text
    assert_equal 'in use', response_xml.at_xpath('//contact:reason', contact: xml_schema).text
  end

  def test_check_contact_without_prefix
    @contact.update_columns(code: "#{@contact.registrar.code}:JOHN-001".upcase)
    assert @contact.code, "#{@contact.registrar.code}:JOHN-001".upcase

    request_xml = <<-XML
      <?xml version="1.0" encoding="UTF-8" standalone="no"?>
      <epp xmlns="#{Xsd::Schema.filename(for_prefix: 'epp-ee')}">
        <command>
          <check>
            <contact:check xmlns:contact="#{Xsd::Schema.filename(for_prefix: 'contact-ee')}">
              <contact:id>JOHN-001</contact:id>
            </contact:check>
          </check>
        </command>
      </epp>
    XML

    post epp_check_path, params: { frame: request_xml },
         headers: { 'HTTP_COOKIE' => 'session=api_bestnames' }

    response_xml = Nokogiri::XML(response.body)
    assert_correct_against_schema response_xml
    assert_epp_response :completed_successfully
    assert_equal "#{@contact.registrar.code}:JOHN-001".upcase, response_xml.at_xpath('//contact:id', contact: xml_schema).text
    assert_equal 'in use', response_xml.at_xpath('//contact:reason', contact: xml_schema).text
  end

  private

  def xml_schema
    Xsd::Schema.filename(for_prefix: 'contact-ee')
  end
end
