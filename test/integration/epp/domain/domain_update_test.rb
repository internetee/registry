require 'test_helper'

class EppDomainUpdateTest < EppTestCase
  def setup
    @domain = domains(:shop)
  end

  def test_update_domain
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

    post '/epp/command/update', { frame: request_xml }, 'HTTP_COOKIE' => 'session=api_bestnames'
    @domain.reload
    assert_equal 'f0ff7d17b0', @domain.transfer_code
    assert_epp_response :completed_successfully
  end

  def test_discarded_domain_cannot_be_updated
    @domain.update!(statuses: [DomainStatus::DELETE_CANDIDATE])

    request_xml = <<-XML
      <?xml version="1.0" encoding="UTF-8" standalone="no"?>
      <epp xmlns="https://epp.tld.ee/schema/epp-ee-1.0.xsd">
        <command>
          <update>
            <domain:update xmlns:domain="https://epp.tld.ee/schema/domain-eis-1.0.xsd">
              <domain:name>shop.test</domain:name>
            </domain:update>
          </update>
        </command>
      </epp>
    XML

    post '/epp/command/update', { frame: request_xml }, 'HTTP_COOKIE' => 'session=api_bestnames'
    assert_epp_response :object_status_prohibits_operation
  end
end
