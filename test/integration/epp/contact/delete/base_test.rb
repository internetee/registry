require 'test_helper'

class EppContactDeleteBaseTest < ActionDispatch::IntegrationTest
  def setup
    @contact = contacts(:john)
  end

  def test_deletes_a_contact_that_is_not_in_use
    @contact = contacts(:not_in_use)

    # https://github.com/internetee/registry/issues/415
    @contact.update_columns(code: @contact.code.upcase)

    request_xml = <<-XML
      <?xml version="1.0" encoding="UTF-8" standalone="no"?>
      <epp xmlns="https://epp.tld.ee/schema/epp-ee-1.0.xsd">
        <command>
          <delete>
            <contact:delete xmlns:contact="https://epp.tld.ee/schema/contact-ee-1.1.xsd">
              <contact:id>not-in-use</contact:id>
            </contact:delete>
          </delete>
        </command>
      </epp>
    XML

    assert_difference 'Contact.count', -1 do
      post '/epp/command/delete', { frame: request_xml }, 'HTTP_COOKIE' => 'session=api_bestnames'
    end
    response_xml = Nokogiri::XML(response.body)
    assert_equal '1000', response_xml.at_css('result')[:code]
    assert_equal 1, response_xml.css('result').size
  end

  def test_contact_that_is_in_use_cannot_be_deleted
    assert_equal 'john-001', @contact.code

    # https://github.com/internetee/registry/issues/415
    @contact.update_columns(code: @contact.code.upcase)

    request_xml = <<-XML
      <?xml version="1.0" encoding="UTF-8" standalone="no"?>
      <epp xmlns="https://epp.tld.ee/schema/epp-ee-1.0.xsd">
        <command>
          <delete>
            <contact:delete xmlns:contact="https://epp.tld.ee/schema/contact-ee-1.1.xsd">
              <contact:id>john-001</contact:id>
            </contact:delete>
          </delete>
        </command>
      </epp>
    XML

    assert_no_difference 'Contact.count' do
      post '/epp/command/delete', { frame: request_xml }, 'HTTP_COOKIE' => 'session=api_bestnames'
    end
    response_xml = Nokogiri::XML(response.body)
    assert_equal '2305', response_xml.at_css('result')[:code]
  end
end