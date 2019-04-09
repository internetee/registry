require 'test_helper'

class EppContactInfoBaseTest < ActionDispatch::IntegrationTest
  setup do
    @contact = contacts(:john)
  end

  def test_returns_valid_response
    assert_equal 'john-001', @contact.code
    assert_equal [Contact::OK, Contact::LINKED], @contact.statuses
    assert_equal 'john@inbox.test', @contact.email
    assert_equal '+555.555', @contact.phone
    assert_equal 'bestnames', @contact.registrar.code
    assert_equal Time.zone.parse('2010-07-05'), @contact.created_at

    # https://github.com/internetee/registry/issues/415
    @contact.update_columns(code: @contact.code.upcase)

    request_xml = <<-XML
      <?xml version="1.0" encoding="UTF-8" standalone="no"?>
      <epp xmlns="https://epp.tld.ee/schema/epp-ee-1.0.xsd">
        <command>
          <info>
            <contact:info xmlns:contact="https://epp.tld.ee/schema/contact-ee-1.1.xsd">
              <contact:id>john-001</contact:id>
            </contact:info>
          </info>
        </command>
      </epp>
    XML

    post '/epp/command/info', { frame: request_xml }, 'HTTP_COOKIE' => 'session=api_bestnames'

    response_xml = Nokogiri::XML(response.body)
    assert_equal '1000', response_xml.at_css('result')[:code]
    assert_equal 1, response_xml.css('result').size
    assert_equal 'JOHN-001', response_xml.at_xpath('//contact:id', contact: xml_schema).text
    assert_equal 'ok', response_xml.at_xpath('//contact:status', contact: xml_schema)['s']
    assert_equal 'john@inbox.test', response_xml.at_xpath('//contact:email', contact: xml_schema)
                                      .text
    assert_equal '+555.555', response_xml.at_xpath('//contact:voice', contact: xml_schema).text
    assert_equal 'bestnames', response_xml.at_xpath('//contact:clID', contact: xml_schema).text
    assert_equal '2010-07-05T00:00:00+03:00', response_xml.at_xpath('//contact:crDate',
                                                                    contact: xml_schema).text
  end

  def test_contact_not_found
    assert_nil Contact.find_by(code: 'non-existing')

    request_xml = <<-XML
      <?xml version="1.0" encoding="UTF-8" standalone="no"?>
      <epp xmlns="https://epp.tld.ee/schema/epp-ee-1.0.xsd">
        <command>
          <info>
            <contact:info xmlns:contact="https://epp.tld.ee/schema/contact-ee-1.1.xsd">
              <contact:id>non-existing</contact:id>
            </contact:info>
          </info>
        </command>
      </epp>
    XML

    post '/epp/command/info', { frame: request_xml }, 'HTTP_COOKIE' => 'session=api_bestnames'

    response_xml = Nokogiri::XML(response.body)
    assert_equal '2303', response_xml.at_css('result')[:code]
  end

  private

  def xml_schema
    'https://epp.tld.ee/schema/contact-ee-1.1.xsd'
  end
end