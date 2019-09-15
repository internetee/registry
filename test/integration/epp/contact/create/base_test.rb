require 'test_helper'

class EppContactCreateBaseTest < EppTestCase
  def test_creates_new_contact_with_required_attributes
    name = 'new'
    email = 'new@registrar.test'
    phone = '+1.2'

    request_xml = <<-XML
      <?xml version="1.0" encoding="UTF-8" standalone="no"?>
      <epp xmlns="https://epp.tld.ee/schema/epp-ee-1.0.xsd">
        <command>
          <create>
            <contact:create xmlns:contact="https://epp.tld.ee/schema/contact-ee-1.1.xsd">
              <contact:postalInfo>
                <contact:name>#{name}</contact:name>
              </contact:postalInfo>
              <contact:voice>#{phone}</contact:voice>
              <contact:email>#{email}</contact:email>
            </contact:create>
          </create>
          <extension>
            <eis:extdata xmlns:eis="https://epp.tld.ee/schema/eis-1.0.xsd">
              <eis:ident type="priv" cc="US">any</eis:ident>
            </eis:extdata>
          </extension>
        </command>
      </epp>
    XML

    assert_difference 'Contact.count' do
      post epp_create_path, params: { frame: request_xml },
           headers: { 'HTTP_COOKIE' => 'session=api_bestnames' }
    end

    assert_epp_response :completed_successfully
    contact = Contact.find_by(name: name)
    assert_equal name, contact.name
    assert_equal email, contact.email
    assert_equal phone, contact.phone
    assert_not_empty contact.code
  end

  def test_respects_custom_code
    name = 'new'
    code = 'custom-id'
    session = epp_sessions(:api_bestnames)

    request_xml = <<-XML
      <?xml version="1.0" encoding="UTF-8" standalone="no"?>
      <epp xmlns="https://epp.tld.ee/schema/epp-ee-1.0.xsd">
        <command>
          <create>
            <contact:create xmlns:contact="https://epp.tld.ee/schema/contact-ee-1.1.xsd">
              <contact:id>#{code}</contact:id>
              <contact:postalInfo>
                <contact:name>#{name}</contact:name>
              </contact:postalInfo>
              <contact:voice>+1.2</contact:voice>
              <contact:email>any@any.test</contact:email>
            </contact:create>
          </create>
          <extension>
            <eis:extdata xmlns:eis="https://epp.tld.ee/schema/eis-1.0.xsd">
              <eis:ident type="priv" cc="US">any</eis:ident>
            </eis:extdata>
          </extension>
        </command>
      </epp>
    XML

    post epp_create_path, params: { frame: request_xml },
         headers: { 'HTTP_COOKIE' => "session=#{session.session_id}" }

    contact = Contact.find_by(name: name)
    assert_equal "#{session.user.registrar.code}:#{code}".upcase, contact.code
  end

  def test_fails_when_required_attributes_are_missing
    request_xml = <<-XML
      <?xml version="1.0" encoding="UTF-8" standalone="no"?>
      <epp xmlns="https://epp.tld.ee/schema/epp-ee-1.0.xsd">
        <command>
          <create>
            <contact:create xmlns:contact="https://epp.tld.ee/schema/contact-ee-1.1.xsd">
              <contact:postalInfo>
                <contact:name>\s</contact:name>
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

    assert_no_difference 'Contact.count' do
      post epp_create_path, params: { frame: request_xml },
           headers: { 'HTTP_COOKIE' => 'session=api_bestnames' }
    end
    assert_epp_response :required_parameter_missing
  end
end
