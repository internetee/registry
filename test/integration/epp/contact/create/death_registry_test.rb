require 'test_helper'

class EppContactCreateDeathRegistryTest < EppTestCase
  DECEASED_IDENT = '39708290069'.freeze

  setup do
    adapter = ENV['shunter_default_adapter'].constantize.new
    adapter&.clear!

    @dir = Dir.mktmpdir
    @death_file = File.join(@dir, 'deaths.txt')
    File.write(@death_file, "#{DECEASED_IDENT};2026-01-01\n")
    ENV['death_registry_file_path'] = @death_file
    ENV['validate_deceased_contacts'] = 'true'
  end

  teardown do
    ENV.delete('death_registry_file_path')
    ENV.delete('validate_deceased_contacts')
    FileUtils.rm_rf(@dir)
  end

  def test_rejects_estonian_private_person_found_in_death_registry
    assert_no_difference 'Contact.count' do
      post epp_create_path, params: { frame: request_xml(DECEASED_IDENT) },
                            headers: { 'HTTP_COOKIE' => 'session=api_bestnames' }
    end

    assert_epp_response :required_parameter_missing
    assert_includes response.body, 'Ident is invalid'
  end

  def test_creates_contact_when_person_is_not_in_death_registry
    File.write(@death_file, "38001010000;2026-01-01\n")

    assert_difference 'Contact.count' do
      post epp_create_path, params: { frame: request_xml(DECEASED_IDENT) },
                            headers: { 'HTTP_COOKIE' => 'session=api_bestnames' }
    end

    assert_epp_response :completed_successfully
    assert_not_nil Contact.find_by(name: 'John Doe').death_registry_checked_at
  end

  private

  def request_xml(ident)
    <<-XML
      <?xml version="1.0" encoding="UTF-8" standalone="no"?>
      <epp xmlns="#{Xsd::Schema.filename(for_prefix: 'epp-ee', for_version: '1.0')}">
        <command>
          <create>
            <contact:create xmlns:contact="#{Xsd::Schema.filename(for_prefix: 'contact-ee', for_version: '1.1')}">
              <contact:postalInfo>
                <contact:name>John Doe</contact:name>
              </contact:postalInfo>
              <contact:voice>+372.51111112</contact:voice>
              <contact:email>john@inbox.test</contact:email>
            </contact:create>
          </create>
          <extension>
            <eis:extdata xmlns:eis="#{Xsd::Schema.filename(for_prefix: 'eis', for_version: '1.0')}">
              <eis:ident type="priv" cc="EE">#{ident}</eis:ident>
            </eis:extdata>
          </extension>
        </command>
      </epp>
    XML
  end
end
