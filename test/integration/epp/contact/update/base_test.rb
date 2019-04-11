require 'test_helper'

class EppContactUpdateBaseTest < ActionDispatch::IntegrationTest
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

    post '/epp/command/update', { frame: request_xml }, 'HTTP_COOKIE' => 'session=api_bestnames'
    @contact.reload

    response_xml = Nokogiri::XML(response.body)
    assert_equal '1000', response_xml.at_css('result')[:code]
    assert_equal 1, response_xml.css('result').size
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

    post '/epp/command/update', { frame: request_xml }, 'HTTP_COOKIE' => 'session=api_bestnames'

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

    post '/epp/command/update', { frame: request_xml }, 'HTTP_COOKIE' => 'session=api_bestnames'

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

    post '/epp/command/update', { frame: request_xml }, 'HTTP_COOKIE' => 'session=api_bestnames'

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

    post '/epp/command/update', { frame: request_xml }, 'HTTP_COOKIE' => 'session=api_bestnames'

    response_xml = Nokogiri::XML(response.body)
    assert_equal '2303', response_xml.at_css('result')[:code]
  end

  private

  def make_contact_free_of_domains_where_it_acts_as_a_registrant(contact)
    other_contact = contacts(:william)
    assert_not_equal other_contact, contact
    Domain.update_all(registrant_id: other_contact)
  end
end