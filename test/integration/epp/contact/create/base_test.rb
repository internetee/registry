require 'test_helper'

class EppContactCreateBaseTest < ActionDispatch::IntegrationTest
  def test_creates_new_contact_with_minimum_required_parameters
    request_xml = <<-XML
      <?xml version="1.0" encoding="UTF-8" standalone="no"?>
      <epp xmlns="https://epp.tld.ee/schema/epp-ee-1.0.xsd">
        <command>
          <create>
            <contact:create xmlns:contact="https://epp.tld.ee/schema/contact-ee-1.1.xsd">
              <contact:postalInfo>
                <contact:name>New</contact:name>
              </contact:postalInfo>
              <contact:voice>+123.4</contact:voice>
              <contact:email>new@inbox.test</contact:email>
            </contact:create>
          </create>
          <extension>
            <eis:extdata xmlns:eis="https://epp.tld.ee/schema/eis-1.0.xsd">
              <eis:ident type="priv" cc="US">test</eis:ident>
            </eis:extdata>
          </extension>
        </command>
      </epp>
    XML

    assert_difference 'Contact.count' do
      post '/epp/command/create', { frame: request_xml }, 'HTTP_COOKIE' => 'session=api_bestnames'
    end

    response_xml = Nokogiri::XML(response.body)
    assert_equal '1000', response_xml.at_css('result')[:code]

    contact = Contact.last
    assert_not_empty contact.code
    assert_equal 'New', contact.name
    assert_equal 'new@inbox.test', contact.email
    assert_equal '+123.4', contact.phone
  end
end