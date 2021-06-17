require 'test_helper'

class EppContactTransferBaseTest < EppTestCase
  # https://github.com/internetee/registry/issues/676
  def test_not_implemented
    request_xml = <<-XML
      <?xml version="1.0" encoding="UTF-8" standalone="no"?>
      <epp xmlns="#{Xsd::Schema.filename(for_prefix: 'epp-ee')}">
        <command>
          <transfer op="request">
            <contact:transfer xmlns:contact="#{Xsd::Schema.filename(for_prefix: 'contact-ee')}">
              <contact:id>any</contact:id>
            </contact:transfer>
          </transfer>
        </command>
      </epp>
    XML

    post epp_transfer_path, params: { frame: request_xml },
         headers: { 'HTTP_COOKIE' => 'session=api_bestnames' }

    response_xml = Nokogiri::XML(response.body)
    assert_correct_against_schema response_xml
    assert_epp_response :unimplemented
  end
end
