require 'test_helper'

class EppContactTransferBaseTest < EppTestCase
  # https://github.com/internetee/registry/issues/676
  def test_not_implemented
    request_xml = <<-XML
      <?xml version="1.0" encoding="UTF-8" standalone="no"?>
      <epp xmlns="https://epp.tld.ee/schema/epp-ee-1.0.xsd">
        <command>
          <transfer op="request">
            <contact:transfer xmlns:contact="https://epp.tld.ee/schema/contact-ee-1.1.xsd">
              <contact:id>any</contact:id>
            </contact:transfer>
          </transfer>
        </command>
      </epp>
    XML

    post epp_transfer_path, { frame: request_xml }, 'HTTP_COOKIE' => 'session=api_bestnames'

    assert_epp_response :unimplemented
  end
end
