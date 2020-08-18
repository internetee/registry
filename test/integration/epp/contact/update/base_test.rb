require 'test_helper'

class EppContactUpdateBaseTest < EppTestCase
  include ActionMailer::TestHelper

  setup do
    @contact = contacts(:john)
    ActionMailer::Base.deliveries.clear
  end

  def test_updates_contact
    assert_equal 'john-001', @contact.code
    assert_not_equal 'new name', @contact.name
    assert_not_equal 'new-email@inbox.test', @contact.email
    assert_not_equal '+123.4', @contact.phone

    # https://github.com/internetee/registry/issues/415
    @contact.update_columns(code: @contact.code.upcase)

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

    post epp_update_path, params: { frame: request_xml },
         headers: { 'HTTP_COOKIE' => 'session=api_bestnames' }
    @contact.reload

    assert_epp_response :completed_successfully
    assert_equal 'new name', @contact.name
    assert_equal 'new-email@inbox.test', @contact.email
    assert_equal '+123.4', @contact.phone
  end

  def test_notifies_contact_by_email_when_email_is_changed
    assert_equal 'john-001', @contact.code
    assert_not_equal 'john-new@inbox.test', @contact.email

    # https://github.com/internetee/registry/issues/415
    @contact.update_columns(code: @contact.code.upcase)

    request_xml = <<-XML
      <?xml version="1.0" encoding="UTF-8" standalone="no"?>
      <epp xmlns="https://epp.tld.ee/schema/epp-ee-1.0.xsd">
        <command>
          <update>
            <contact:update xmlns:contact="https://epp.tld.ee/schema/contact-ee-1.1.xsd">
              <contact:id>john-001</contact:id>
              <contact:chg>
                <contact:email>john-new@inbox.test</contact:email>
              </contact:chg>
            </contact:update>
          </update>
        </command>
      </epp>
    XML

    post epp_update_path, params: { frame: request_xml },
         headers: { 'HTTP_COOKIE' => 'session=api_bestnames' }

    assert_emails 1
  end

  def test_skips_notifying_contact_when_email_is_not_changed
    assert_equal 'john-001', @contact.code
    assert_equal 'john@inbox.test', @contact.email

    # https://github.com/internetee/registry/issues/415
    @contact.update_columns(code: @contact.code.upcase)

    request_xml = <<-XML
      <?xml version="1.0" encoding="UTF-8" standalone="no"?>
      <epp xmlns="https://epp.tld.ee/schema/epp-ee-1.0.xsd">
        <command>
          <update>
            <contact:update xmlns:contact="https://epp.tld.ee/schema/contact-ee-1.1.xsd">
              <contact:id>john-001</contact:id>
              <contact:chg>
                <contact:email>john@inbox.test</contact:email>
              </contact:chg>
            </contact:update>
          </update>
        </command>
      </epp>
    XML

    post epp_update_path, params: { frame: request_xml },
         headers: { 'HTTP_COOKIE' => 'session=api_bestnames' }

    assert_no_emails
  end

  def test_skips_notifying_a_contact_when_a_contact_is_not_a_registrant
    assert_equal 'john-001', @contact.code
    assert_not_equal 'john-new@inbox.test', @contact.email

    make_contact_free_of_domains_where_it_acts_as_a_registrant(@contact)
    assert_not @contact.registrant?

    # https://github.com/internetee/registry/issues/415
    @contact.update_columns(code: @contact.code.upcase)

    request_xml = <<-XML
      <?xml version="1.0" encoding="UTF-8" standalone="no"?>
      <epp xmlns="https://epp.tld.ee/schema/epp-ee-1.0.xsd">
        <command>
          <update>
            <contact:update xmlns:contact="https://epp.tld.ee/schema/contact-ee-1.1.xsd">
              <contact:id>john-001</contact:id>
              <contact:chg>
                <contact:email>john-new@inbox.test</contact:email>
              </contact:chg>
            </contact:update>
          </update>
        </command>
      </epp>
    XML

    post epp_update_path, params: { frame: request_xml },
         headers: { 'HTTP_COOKIE' => 'session=api_bestnames' }

    assert_no_emails
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

    post epp_update_path, params: { frame: request_xml },
         headers: { 'HTTP_COOKIE' => 'session=api_bestnames' }

    assert_epp_response :object_does_not_exist
  end

  def test_ident_code_cannot_be_updated
    new_ident_code = '12345'
    assert_not_equal new_ident_code, @contact.ident

    # https://github.com/internetee/registry/issues/415
    @contact.update_columns(code: @contact.code.upcase)

    request_xml = <<-XML
      <?xml version="1.0" encoding="UTF-8" standalone="no"?>
      <epp xmlns="https://epp.tld.ee/schema/epp-ee-1.0.xsd">
        <command>
          <update>
            <contact:update xmlns:contact="https://epp.tld.ee/schema/contact-ee-1.1.xsd">
              <contact:id>#{@contact.code}</contact:id>
              <contact:chg>
                <contact:postalInfo>
                </contact:postalInfo>
              </contact:chg>
            </contact:update>
          </update>
          <extension>
            <eis:extdata xmlns:eis="https://epp.tld.ee/schema/eis-1.0.xsd">
              <eis:ident cc="#{@contact.ident_country_code}" type="#{@contact.ident_type}">#{new_ident_code}</eis:ident>
            </eis:extdata>
          </extension>
        </command>
      </epp>
    XML
    assert_no_changes -> { @contact.updated_at } do
      post epp_update_path, params: { frame: request_xml },
           headers: { 'HTTP_COOKIE' => 'session=api_bestnames' }
    end
    assert_epp_response :data_management_policy_violation
  end

  # https://github.com/internetee/registry/issues/576
  def test_ident_type_and_ident_country_code_can_be_updated_when_absent
    @contact.update_columns(ident: 'test', ident_type: nil, ident_country_code: nil)

    # https://github.com/internetee/registry/issues/415
    @contact.update_columns(code: @contact.code.upcase)

    request_xml = <<-XML
      <?xml version="1.0" encoding="UTF-8" standalone="no"?>
      <epp xmlns="https://epp.tld.ee/schema/epp-ee-1.0.xsd">
        <command>
          <update>
            <contact:update xmlns:contact="https://epp.tld.ee/schema/contact-ee-1.1.xsd">
              <contact:id>#{@contact.code}</contact:id>
              <contact:chg>
                <contact:postalInfo/>
              </contact:chg>
            </contact:update>
          </update>
          <extension>
            <eis:extdata xmlns:eis="https://epp.tld.ee/schema/eis-1.0.xsd">
              <eis:ident cc="US" type="priv">#{@contact.ident}</eis:ident>
            </eis:extdata>
          </extension>
        </command>
      </epp>
    XML
    post epp_update_path, params: { frame: request_xml },
         headers: { 'HTTP_COOKIE' => 'session=api_bestnames' }

    assert_epp_response :completed_successfully
  end

  def test_updates_address_when_address_processing_turned_on
    @contact.update_columns(code: @contact.code.upcase)
    Setting.address_processing = true

    street = '123 Example'
    city = 'Tallinn'
    state = 'Harjumaa'
    zip = '123456'
    country_code = 'EE'

    request_xml = <<-XML
    <?xml version="1.0" encoding="UTF-8" standalone="no"?>
    <epp xmlns="https://epp.tld.ee/schema/epp-ee-1.0.xsd">
      <command>
        <update>
          <contact:update xmlns:contact="https://epp.tld.ee/schema/contact-ee-1.1.xsd">
            <contact:id>#{@contact.code}</contact:id>
            <contact:chg>
              <contact:postalInfo>
                <contact:addr>
                  <contact:street>#{street}</contact:street>
                  <contact:city>#{city}</contact:city>
                  <contact:sp>#{state}</contact:sp>
                  <contact:pc>#{zip}</contact:pc>
                  <contact:cc>#{country_code}</contact:cc>
                </contact:addr>
              </contact:postalInfo>
            </contact:chg>
          </contact:update>
        </update>
      </command>
    </epp>
    XML

    post epp_update_path, params: { frame: request_xml },
         headers: { 'HTTP_COOKIE' => 'session=api_bestnames' }

    assert_epp_response :completed_successfully
    @contact.reload

    assert_equal city, @contact.city
    assert_equal street, @contact.street
    assert_equal zip, @contact.zip
    assert_equal country_code, @contact.country_code
    assert_equal state, @contact.state
  end

  def test_does_not_update_address_when_address_processing_turned_off
    @contact.update_columns(code: @contact.code.upcase)

    street = '123 Example'
    city = 'Tallinn'
    state = 'Harjumaa'
    zip = '123456'
    country_code = 'EE'

    request_xml = <<-XML
    <?xml version="1.0" encoding="UTF-8" standalone="no"?>
    <epp xmlns="https://epp.tld.ee/schema/epp-ee-1.0.xsd">
      <command>
        <update>
          <contact:update xmlns:contact="https://epp.tld.ee/schema/contact-ee-1.1.xsd">
            <contact:id>#{@contact.code}</contact:id>
            <contact:chg>
              <contact:postalInfo>
                <contact:addr>
                  <contact:street>#{street}</contact:street>
                  <contact:city>#{city}</contact:city>
                  <contact:sp>#{state}</contact:sp>
                  <contact:pc>#{zip}</contact:pc>
                  <contact:cc>#{country_code}</contact:cc>
                </contact:addr>
              </contact:postalInfo>
            </contact:chg>
          </contact:update>
        </update>
      </command>
    </epp>
    XML

    post epp_update_path, params: { frame: request_xml },
         headers: { 'HTTP_COOKIE' => 'session=api_bestnames' }

    assert_epp_response :completed_without_address
    @contact.reload

    assert_nil @contact.city
    assert_nil @contact.street
    assert_nil @contact.zip
    assert_nil @contact.country_code
    assert_nil @contact.state
  end

  private

  def make_contact_free_of_domains_where_it_acts_as_a_registrant(contact)
    other_contact = contacts(:william)
    assert_not_equal other_contact, contact
    Domain.update_all(registrant_id: other_contact.id)
  end
end
