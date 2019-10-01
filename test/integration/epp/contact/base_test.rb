require 'test_helper'

class EppContactBaseTest < EppTestCase
  def test_non_existent_contact
    request_xml = <<-XML
      <?xml version="1.0" encoding="UTF-8" standalone="no"?>
      <epp xmlns="https://epp.tld.ee/schema/epp-ee-1.0.xsd">
        <command>
          <info>
            <contact:info xmlns:contact="https://epp.tld.ee/schema/contact-ee-1.1.xsd">
              <contact:id>non-existent</contact:id>
            </contact:info>
          </info>
        </command>
      </epp>
    XML
    post epp_info_path, { frame: request_xml }, 'HTTP_COOKIE' => 'session=api_bestnames'

    assert_epp_response :object_does_not_exist
  end
end
