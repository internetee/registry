require 'test_helper'
require 'application_system_test_case'

class AdminAreaBlockedDomainsIntegrationTest < JavaScriptApplicationSystemTestCase  
  setup do
    WebMock.allow_net_connect!
    sign_in users(:admin)
    @domain = domains(:shop)
  end

  def test_t
    new_registrant = contacts(:william)
    assert_not_equal new_registrant, @domain.registrant

    puts new_registrant.name
    request_xml = <<-XML
      <?xml version="1.0" encoding="UTF-8" standalone="no"?>
      <epp xmlns="https://epp.tld.ee/schema/epp-ee-1.0.xsd">
        <command>
          <update>
            <domain:update xmlns:domain="https://epp.tld.ee/schema/domain-eis-1.0.xsd">
              <domain:name>#{@domain.name}</domain:name>
                <domain:chg>
                  <domain:registrant>#{new_registrant.code}</domain:registrant>
                </domain:chg>
            </domain:update>
          </update>
          <extension>
            <eis:extdata xmlns:eis="https://epp.tld.ee/schema/eis-1.0.xsd">
              <eis:legalDocument type="pdf">#{'test' * 2000}</eis:legalDocument>
            </eis:extdata>
          </extension>
        </command>
      </epp>
    XML

    post epp_update_path, params: { frame: request_xml },
          headers: { 'HTTP_COOKIE' => 'session=api_bestnames' }
    @domain.reload

    puts @domain.registrant
  end

  private

  def update_registrant_of_domain
    new_registrant = contacts(:william)
    assert_not_equal new_registrant, @domain.registrant

    @domain.registrant
    request_xml = <<-XML
      <?xml version="1.0" encoding="UTF-8" standalone="no"?>
      <epp xmlns="https://epp.tld.ee/schema/epp-ee-1.0.xsd">
        <command>
          <update>
            <domain:update xmlns:domain="https://epp.tld.ee/schema/domain-eis-1.0.xsd">
              <domain:name>#{@domain.name}</domain:name>
                <domain:chg>
                  <domain:registrant>#{new_registrant.code}</domain:registrant>
                </domain:chg>
            </domain:update>
          </update>
          <extension>
            <eis:extdata xmlns:eis="https://epp.tld.ee/schema/eis-1.0.xsd">
              <eis:legalDocument type="pdf">#{'test' * 2000}</eis:legalDocument>
            </eis:extdata>
          </extension>
        </command>
      </epp>
    XML

    post epp_update_path, params: { frame: request_xml },
          headers: { 'HTTP_COOKIE' => 'session=api_bestnames' }
    @domain.reload

    # puts response.body
    puts @domain.registrant
  end

end