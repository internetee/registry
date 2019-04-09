require 'test_helper'

class EppContactUpdateBaseTest < ActionDispatch::IntegrationTest
  setup do
    @contact = contacts(:john)
  end

  def test_updates_contact
    assert_equal 'john-001', @contact.code
    assert_not_equal 'new name', @contact.name
    assert_not_equal 'new-email@inbox.test', @contact.email
    assert_not_equal '+123.4', @contact.phone

    request_xml = <<-XML
      <?xml version="1.0" encoding="UTF-8" standalone="no"?>
      <epp xmlns="https://epp.tld.ee/schema/epp-ee-1.0.xsd">
        <command>
          <update>
            <contact:update xmlns:contact="https://epp.tld.ee/schema/contact-ee-1.1.xsd">
              <contact:id>john-001</contact:id>
              <contact:chg>
                <contact:postalInfo>
                  <contact:name>new name</contact:name>
                </contact:postalInfo>
                <contact:voice>+123.4</contact:voice>
                <contact:email>new-email@inbox.test</contact:email>
              </contact:chg>
            </contact:update>
          </update>
        </command>
      </epp>
    XML

    post '/epp/command/update', { frame: request_xml }, 'HTTP_COOKIE' => 'session=api_bestnames'
    @contact.reload

    response_xml = Nokogiri::XML(response.body)
    assert_equal '1000', response_xml.at_css('result')[:code]
    assert_equal 1, response_xml.css('result').size
    assert_equal 'new name', @contact.name
    assert_equal 'new-email@inbox.test', @contact.email
    assert_equal '+123.4', @contact.phone
  end

  def test_non_existing_contact
    assert_nil Contact.find_by(code: 'non-existing')

    request_xml = <<-XML
      <?xml version="1.0" encoding="UTF-8" standalone="no"?>
      <epp xmlns="https://epp.tld.ee/schema/epp-ee-1.0.xsd">
        <command>
          <update>
            <contact:update xmlns:contact="https://epp.tld.ee/schema/contact-ee-1.1.xsd">
              <contact:id>non-existing</contact:id>
              <contact:chg>
                <contact:postalInfo>
                  <contact:name>any</contact:name>
                </contact:postalInfo>
              </contact:chg>
            </contact:update>
          </update>
        </command>
      </epp>
    XML

    post '/epp/command/update', { frame: request_xml }, 'HTTP_COOKIE' => 'session=api_bestnames'

    response_xml = Nokogiri::XML(response.body)
    assert_equal '2303', response_xml.at_css('result')[:code]
  end
end