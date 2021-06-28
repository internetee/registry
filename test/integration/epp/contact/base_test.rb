require 'test_helper'

class EppContactBaseTest < EppTestCase
  def test_non_existent_contact
    request_xml = <<-XML
      <?xml version="1.0" encoding="UTF-8" standalone="no"?>
      <epp xmlns="#{Xsd::Schema.filename(for_prefix: 'epp-ee', for_version: '1.0')}">
        <command>
          <info>
            <contact:info xmlns:contact="#{Xsd::Schema.filename(for_prefix: 'contact-ee', for_version: '1.1')}">
              <contact:id>non-existent</contact:id>
            </contact:info>
          </info>
        </command>
      </epp>
    XML
    post epp_info_path, params: { frame: request_xml },
         headers: { 'HTTP_COOKIE' => 'session=api_bestnames' }

    assert_epp_response :object_does_not_exist
  end
end
