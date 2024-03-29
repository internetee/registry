require 'test_helper'
require 'deserializers/xml/contact'

class DeserializersXmlContactTest < ActiveSupport::TestCase
  def test_trims_empty_values
    xml_string = <<-XML
    XML

    nokogiri_frame = Nokogiri::XML(xml_string).remove_namespaces!
    instance = ::Deserializers::Xml::Contact.new(nokogiri_frame)
    assert_equal instance.call, {}
  end

  def test_handles_update
    xml_string = <<-XML
      <?xml version="1.0" encoding="UTF-8" standalone="no"?>
      <epp xmlns="#{Xsd::Schema.filename(for_prefix: 'epp-ee', for_version: '1.0')}">
        <command>
          <update>
            <contact:update xmlns:contact="#{Xsd::Schema.filename(for_prefix: 'contact-ee', for_version: '1.1')}">
              <contact:id>john-001</contact:id>
              <contact:chg>
                <contact:postalInfo>
                  <contact:name>new name</contact:name>
                  <contact:org>Org</contact:org>
                </contact:postalInfo>
                <contact:voice>+123.4</contact:voice>
                <contact:email>new-email@inbox.test</contact:email>
              </contact:chg>
            </contact:update>
          </update>
        </command>
      </epp>
    XML

    nokogiri_frame = Nokogiri::XML(xml_string).remove_namespaces!
    instance = ::Deserializers::Xml::Contact.new(nokogiri_frame)
    assert_equal instance.call, { name: 'new name',
                                  org_name: 'Org',
                                  email: 'new-email@inbox.test',
                                  phone: '+123.4' }
  end

  def test_handles_create
    name = 'new'
    email = 'new@registrar.test'
    phone = '+1.2'

    xml_string = <<-XML
      <?xml version="1.0" encoding="UTF-8" standalone="no"?>
      <epp xmlns="#{Xsd::Schema.filename(for_prefix: 'epp-ee', for_version: '1.0')}">
        <command>
          <create>
            <contact:create xmlns:contact="#{Xsd::Schema.filename(for_prefix: 'contact-ee', for_version: '1.1')}">
              <contact:postalInfo>
                <contact:name>#{name}</contact:name>
              </contact:postalInfo>
              <contact:voice>#{phone}</contact:voice>
              <contact:email>#{email}</contact:email>
            </contact:create>
          </create>
          <extension>
            <eis:extdata xmlns:eis="#{Xsd::Schema.filename(for_prefix: 'eis', for_version: '1.0')}">
              <eis:ident type="priv" cc="US">any</eis:ident>
            </eis:extdata>
          </extension>
        </command>
      </epp>
    XML

    nokogiri_frame = Nokogiri::XML(xml_string).remove_namespaces!
    instance = ::Deserializers::Xml::Contact.new(nokogiri_frame)
    assert_equal instance.call, { name: 'new', email: 'new@registrar.test', phone: '+1.2' }
  end

  def test_handles_statuses
    xml_string = <<-XML
      <?xml version="1.0" encoding="UTF-8" standalone="no"?>
      <epp xmlns="#{Xsd::Schema.filename(for_prefix: 'epp-ee', for_version: '1.0')}">
        <command>
          <update>
            <contact:update xmlns:contact="#{Xsd::Schema.filename(for_prefix: 'contact-ee', for_version: '1.1')}">
              <contact:id>john-001</contact:id>
              <contact:chg>
                <contact:postalInfo>
                  <contact:name>new name</contact:name>
                </contact:postalInfo>
                <contact:voice>+123.4</contact:voice>
                <contact:email>new-email@inbox.test</contact:email>
              </contact:chg>
              <contact:add>
                <contact:status s="clientDeleteProhibited" lang="en">Payment overdue.</contact:status>
                <contact:status s="clientUpdateProhibited"/>
              </contact:add>
              <contact:rem>
                <contact:status s="pendingDelete"/>
              </contact:rem>
            </contact:update>
          </update>
        </command>
      </epp>
    XML

    nokogiri_frame = Nokogiri::XML(xml_string).remove_namespaces!
    instance = ::Deserializers::Xml::Contact.new(nokogiri_frame)
    assert_equal instance.call, { name: 'new name',
                                  email: 'new-email@inbox.test',
                                  phone: '+123.4',
                                  statuses_to_add: ['clientDeleteProhibited',
                                                    'clientUpdateProhibited'],
                                  statuses_to_remove: ['pendingDelete']
                                }
  end
end
