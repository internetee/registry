require 'test_helper'
require 'deserializers/xml/legal_document'

class DeserializersXmlLegalDocumentTest < ActiveSupport::TestCase
  def test_returns_nil_when_required_fields_not_present
    xml_string = <<-XML
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

    nokogiri_frame = Nokogiri::XML(xml_string).remove_namespaces!
    instance = ::Deserializers::Xml::LegalDocument.new(nokogiri_frame)

    assert_nil instance.call
  end

  def test_returns_hash_when_document_exists
    xml_string = <<-XML
      <?xml version="1.0" encoding="UTF-8" standalone="no"?>
      <epp xmlns="https://epp.tld.ee/schema/epp-ee-1.0.xsd">
        <command>
          <delete>
            <contact:delete xmlns:contact="https://epp.tld.ee/schema/contact-ee-1.1.xsd">
              <contact:id>FIRST0:SH2027223711</contact:id>
              <contact:authInfo>
                <contact:pw>wrong password</contact:pw>
              </contact:authInfo>
            </contact:delete>
          </delete>
          <extension>
            <eis:extdata xmlns:eis="https://epp.tld.ee/schema/eis-1.0.xsd">
              <eis:ident type="priv" cc="EE">37605030299</eis:ident>
              <eis:legalDocument type="pdf">dGVzdCBmYWlsCg==</eis:legalDocument>
            </eis:extdata>
          </extension>
          <clTRID>ABC-12345</clTRID>
        </command>
      </epp>
    XML

    nokogiri_frame = Nokogiri::XML(xml_string).remove_namespaces!
    instance = ::Deserializers::Xml::LegalDocument.new(nokogiri_frame)
    expected_result = { body: "dGVzdCBmYWlsCg==", type: "pdf" }

    assert_equal expected_result, instance.call
  end
end
