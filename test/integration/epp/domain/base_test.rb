require 'test_helper'

class EppDomainBaseTest < EppTestCase
  def test_non_existent_domain
    request_xml = <<-XML
      <?xml version="1.0" encoding="UTF-8" standalone="no"?>
      <epp xmlns="https://epp.tld.ee/schema/epp-ee-1.0.xsd">
        <command>
          <info>
            <domain:info xmlns:domain="https://epp.tld.ee/schema/domain-eis-1.0.xsd">
              <domain:name>non-existent.test</domain:name>
            </domain:info>
          </info>
        </command>
      </epp>
    XML
    post '/epp/command/info', { frame: request_xml }, 'HTTP_COOKIE' => 'session=api_bestnames'

    assert_epp_response :object_does_not_exist
  end
end
