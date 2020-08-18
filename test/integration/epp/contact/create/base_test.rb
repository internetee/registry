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

  def test_responces_error_with_email_error
    name = 'new'
    email = 'new@registrar@test'
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

    assert_no_difference 'Contact.count' do
      post epp_create_path, params: { frame: request_xml },
           headers: { 'HTTP_COOKIE' => 'session=api_bestnames' }
    end

    assert_epp_response :parameter_value_syntax_error
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

  def test_does_not_save_address_when_address_processing_turned_off
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
                <contact:addr>
                  <contact:street>123 Example</contact:street>
                  <contact:city>Tallinn</contact:city>
                  <contact:sp>FFF</contact:sp>
                  <contact:pc>123456</contact:pc>
                  <contact:cc>EE</contact:cc>
                </contact:addr>
              </contact:postalInfo>
              <contact:voice>#{phone}</contact:voice>
              <contact:email>#{email}</contact:email>
            </contact:create>
          </create>
          <extension>
            <eis:extdata xmlns:eis="https://epp.tld.ee/schema/eis-1.0.xsd">
              <eis:ident type="priv" cc="US">123</eis:ident>
            </eis:extdata>
          </extension>
        </command>
      </epp>
    XML

    assert_difference 'Contact.count' do
      post epp_create_path, params: { frame: request_xml },
           headers: { 'HTTP_COOKIE' => 'session=api_bestnames' }
    end

    assert_epp_response :completed_without_address
    contact = Contact.find_by(name: name)
    assert_equal name, contact.name
    assert_equal email, contact.email
    assert_equal phone, contact.phone
    assert_not_empty contact.code
    assert_nil contact.city
    assert_nil contact.street
    assert_nil contact.zip
    assert_nil contact.country_code
    assert_nil contact.state
  end

  def test_saves_address_when_address_processing_turned_on
    Setting.address_processing = true

    name = 'new'
    email = 'new@registrar.test'
    phone = '+1.2'
    street = '123 Example'
    city = 'Tallinn'
    state = 'Harjumaa'
    zip = '123456'
    country_code = 'EE'

    request_xml = <<-XML
      <?xml version="1.0" encoding="UTF-8" standalone="no"?>
      <epp xmlns="https://epp.tld.ee/schema/epp-ee-1.0.xsd">
        <command>
          <create>
            <contact:create xmlns:contact="https://epp.tld.ee/schema/contact-ee-1.1.xsd">
              <contact:postalInfo>
                <contact:name>#{name}</contact:name>
                <contact:addr>
                  <contact:street>#{street}</contact:street>
                  <contact:city>#{city}</contact:city>
                  <contact:sp>#{state}</contact:sp>
                  <contact:pc>#{zip}</contact:pc>
                  <contact:cc>#{country_code}</contact:cc>
                </contact:addr>
              </contact:postalInfo>
              <contact:voice>#{phone}</contact:voice>
              <contact:email>#{email}</contact:email>
            </contact:create>
          </create>
          <extension>
            <eis:extdata xmlns:eis="https://epp.tld.ee/schema/eis-1.0.xsd">
              <eis:ident type="priv" cc="US">123</eis:ident>
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
    assert_equal city, contact.city
    assert_equal street, contact.street
    assert_equal zip, contact.zip
    assert_equal country_code, contact.country_code
    assert_equal state, contact.state
  end
end
