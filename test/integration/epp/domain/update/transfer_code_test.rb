require 'test_helper'

class EppDomainUpdateTest < ActionDispatch::IntegrationTest
  def setup
    login_as users(:api_bestnames)
  end

  def test_overwrites_existing
    request_xml = <<-XML
      <?xml version="1.0" encoding="UTF-8" standalone="no"?>
      <epp xmlns="https://epp.tld.ee/schema/epp-ee-1.0.xsd">
        <command>
          <update>
            <domain:update xmlns:domain="https://epp.tld.ee/schema/domain-eis-1.0.xsd">
              <domain:name>shop.test</domain:name>
                <domain:chg>
                  <domain:authInfo>
                    <domain:pw>f0ff7d17b0</domain:pw>
                  </domain:authInfo>
                </domain:chg>
            </domain:update>
          </update>
        </command>
      </epp>
    XML

    session_id = epp_sessions(:api_bestnames).session_id
    post '/epp/command/update', { frame: request_xml }, { 'HTTP_COOKIE' => "session=#{session_id}" }
    assert_equal 'f0ff7d17b0', domains(:shop).transfer_code
  end
end
