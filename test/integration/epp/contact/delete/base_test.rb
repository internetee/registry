require 'test_helper'

class EppContactDeleteBaseTest < EppTestCase
  def test_deletes_contact
    contact = deletable_contact

    # https://github.com/internetee/registry/issues/415
    contact.update_columns(code: contact.code.upcase)

    request_xml = <<-XML
      <?xml version="1.0" encoding="UTF-8" standalone="no"?>
      <epp xmlns="#{Xsd::Schema.filename(for_prefix: 'epp-ee')}">
        <command>
          <delete>
            <contact:delete xmlns:contact="#{Xsd::Schema.filename(for_prefix: 'contact-ee')}">
              <contact:id>#{contact.code}</contact:id>
            </contact:delete>
          </delete>
        </command>
      </epp>
    XML

    assert_difference 'Contact.count', -1 do
      post epp_delete_path, params: { frame: request_xml },
           headers: { 'HTTP_COOKIE' => 'session=api_bestnames' }
    end

    response_xml = Nokogiri::XML(response.body)
    assert_correct_against_schema response_xml
    assert_epp_response :completed_successfully
  end

  def test_delete_contact_with_server_delete_prohibited
    contact = deletable_contact
    contact.update(statuses: Contact::SERVER_DELETE_PROHIBITED)
    assert contact.statuses.include? Contact::SERVER_DELETE_PROHIBITED

    contact.update_columns(code: contact.code.upcase)

    request_xml = <<-XML
      <?xml version="1.0" encoding="UTF-8" standalone="no"?>
        <epp xmlns="#{Xsd::Schema.filename(for_prefix: 'epp-ee')}">
          <command>
            <delete>
              <contact:delete xmlns:contact="#{Xsd::Schema.filename(for_prefix: 'contact-ee')}">
                <contact:id>#{contact.code.upcase}</contact:id>
              </contact:delete>
            </delete>
          </command>
        </epp>
    XML

    post epp_delete_path, params: { frame: request_xml },
        headers: { 'HTTP_COOKIE' => 'session=api_bestnames' }

    response_xml = Nokogiri::XML(response.body)
    assert_correct_against_schema response_xml
    assert Contact.exists?(id: contact.id)
    assert_epp_response :object_status_prohibits_operation
  end

  def test_delete_contact_with_client_delete_prohibited
    contact = deletable_contact
    contact.update(statuses: Contact::CLIENT_DELETE_PROHIBITED)
    assert contact.statuses.include? Contact::CLIENT_DELETE_PROHIBITED

    contact.update_columns(code: contact.code.upcase)

    request_xml = <<-XML
      <?xml version="1.0" encoding="UTF-8" standalone="no"?>
        <epp xmlns="#{Xsd::Schema.filename(for_prefix: 'epp-ee')}">
          <command>
            <delete>
              <contact:delete xmlns:contact="#{Xsd::Schema.filename(for_prefix: 'contact-ee')}">
                <contact:id>#{contact.code.upcase}</contact:id>
              </contact:delete>
            </delete>
          </command>
        </epp>
    XML

    post epp_delete_path, params: { frame: request_xml },
        headers: { 'HTTP_COOKIE' => 'session=api_bestnames' }

    response_xml = Nokogiri::XML(response.body)
    assert_correct_against_schema response_xml
    assert Contact.exists?(id: contact.id)
    assert_epp_response :object_status_prohibits_operation
  end

  def test_undeletable_cannot_be_deleted
    contact = contacts(:john)
    assert_not contact.deletable?

    # https://github.com/internetee/registry/issues/415
    contact.update_columns(code: contact.code.upcase)

    request_xml = <<-XML
      <?xml version="1.0" encoding="UTF-8" standalone="no"?>
      <epp xmlns="#{Xsd::Schema.filename(for_prefix: 'epp-ee')}">
        <command>
          <delete>
            <contact:delete xmlns:contact="#{Xsd::Schema.filename(for_prefix: 'contact-ee')}">
              <contact:id>#{contact.code}</contact:id>
            </contact:delete>
          </delete>
        </command>
      </epp>
    XML

    assert_no_difference 'Contact.count' do
      post epp_delete_path, params: { frame: request_xml },
           headers: { 'HTTP_COOKIE' => 'session=api_bestnames' }
    end
    response_xml = Nokogiri::XML(response.body)
    assert_correct_against_schema response_xml
    assert_epp_response :object_association_prohibits_operation
  end

  private

  def deletable_contact
    Domain.update_all(registrant_id: contacts(:william).id)
    DomainContact.delete_all
    contacts(:john)
  end
end
