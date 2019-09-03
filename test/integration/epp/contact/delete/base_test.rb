require 'test_helper'

class EppContactDeleteBaseTest < EppTestCase
  def test_deletes_contact
    contact = deletable_contact

    # https://github.com/internetee/registry/issues/415
    contact.update_columns(code: contact.code.upcase)

    request_xml = <<-XML
      <?xml version="1.0" encoding="UTF-8" standalone="no"?>
      <epp xmlns="https://epp.tld.ee/schema/epp-ee-1.0.xsd">
        <command>
          <delete>
            <contact:delete xmlns:contact="https://epp.tld.ee/schema/contact-ee-1.1.xsd">
              <contact:id>#{contact.code}</contact:id>
            </contact:delete>
          </delete>
        </command>
      </epp>
    XML

    assert_difference 'Contact.count', -1 do
      post '/epp/command/delete', { frame: request_xml }, 'HTTP_COOKIE' => 'session=api_bestnames'
    end
    assert_epp_response :completed_successfully
  end

  def test_undeletable_cannot_be_deleted
    contact = contacts(:john)
    assert_not contact.deletable?

    # https://github.com/internetee/registry/issues/415
    contact.update_columns(code: contact.code.upcase)

    request_xml = <<-XML
      <?xml version="1.0" encoding="UTF-8" standalone="no"?>
      <epp xmlns="https://epp.tld.ee/schema/epp-ee-1.0.xsd">
        <command>
          <delete>
            <contact:delete xmlns:contact="https://epp.tld.ee/schema/contact-ee-1.1.xsd">
              <contact:id>#{contact.code}</contact:id>
            </contact:delete>
          </delete>
        </command>
      </epp>
    XML

    assert_no_difference 'Contact.count' do
      post '/epp/command/delete', { frame: request_xml }, 'HTTP_COOKIE' => 'session=api_bestnames'
    end
    assert_epp_response :object_association_prohibits_operation
  end

  private

  def deletable_contact
    Domain.update_all(registrant_id: contacts(:william))
    DomainContact.delete_all
    contacts(:john)
  end
end