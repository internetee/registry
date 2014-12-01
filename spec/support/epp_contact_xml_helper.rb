module EppContactXmlHelper
  def create_contact_xml(xml_params = {})
    defaults = {
      postalInfo: {
        name: { value: 'John Doe' },
        addr: {
          street: { value: '123 Example' },
          city: { value: 'Tallinn' },
          cc: { value: 'EE' }
        }
      },
      voice: { value: '+372.1234567' },
      email: { value: 'test@example.example' },
      ident: { value: '37605030299' }
    }

    xml_params = defaults.deep_merge(xml_params)
    EppXml::Contact.create(xml_params)
  end

  def update_contact_xml(xml_params = {})
    defaults = {
      id: { value: 'asd123123er' },
      authInfo: { pw: { value: 'password' } },
      chg: {
        postalInfo: {
          name: { value: 'John Doe Edited' }
        },
        voice: { value: '+372.7654321' },
        email: { value: 'edited@example.example' },
        disclose: {
          value: {
            voice: { value: '' },
            email: { value: '' }
          }, attrs: { flag: '0' }
        }
      }
    }
    xml_params = defaults.deep_merge(xml_params)
    EppXml::Contact.update(xml_params)
  end

  def delete_contact_xml(xml_params = {})
    defaults = { id: { value: 'sh8012' } }
    xml_params = defaults.deep_merge(xml_params)
    EppXml::Contact.delete(xml_params)
  end

  def info_contact_xml(xml_params = {})
    defaults = { id: { value: 'sh8012' }, authInfo: { pw: { value: 'password' } } }
    xml_params = defaults.deep_merge(xml_params)
    EppXml::Contact.info(xml_params)
  end

  def check_contact_xml(xml_params = {})
    defaults = {
      id: { value: 'ad123c3' }
    }
    xml_params = defaults.deep_merge(xml_params)
    EppXml::Contact.check(xml_params)
  end

  def check_multiple_contacts_xml
    '<?xml version="1.0" encoding="UTF-8" standalone="no"?>
    <epp xmlns="urn:ietf:params:xml:ns:epp-1.0">
      <command>
        <check>
          <contact:check
           xmlns:contact="urn:ietf:params:xml:ns:contact-1.0">
            <contact:id>check-1234</contact:id>
            <contact:id>check-4321</contact:id>
          </contact:check>
        </check>
        <clTRID>ABC-12345</clTRID>
      </command>
    </epp>'
  end
end

RSpec.configure do |c|
  c.include EppContactXmlHelper
end
