require 'test_helper'

class EppDomainUpdateReplaceDnsTest < EppTestCase
  include ActionMailer::TestHelper
  include ActiveJob::TestHelper

  setup do
    @domain = domains(:shop)
    @contact = contacts(:john)
    @dnskey = dnskeys(:one)
    @dnskey.update(domain: @domain)
    @original_registrant_change_verification =
      Setting.request_confirmation_on_registrant_change_enabled
    ActionMailer::Base.deliveries.clear
  end

  teardown do
    Setting.request_confirmation_on_registrant_change_enabled =
      @original_registrant_change_verification
  end

  def test_remove_dnskey_if_explicitly_set
    request_xml = <<-XML
      <?xml version="1.0" encoding="UTF-8" standalone="no"?>
      <epp xmlns="#{Xsd::Schema.filename(for_prefix: 'epp-ee', for_version: '1.0')}">
        <command>
          <update>
            <domain:update xmlns:domain="#{Xsd::Schema.filename(for_prefix: 'domain-ee', for_version: '1.2')}">
              <domain:name>shop.test</domain:name>
                <domain:chg>
                  <domain:authInfo>
                    <domain:pw>f0ff7d17b0</domain:pw>
                  </domain:authInfo>
                </domain:chg>
            </domain:update>
          </update>
          <extension>
          <secDNS:update xmlns:secDNS="urn:ietf:params:xml:ns:secDNS-1.1">
            <secDNS:rem>
              <secDNS:keyData>
                <secDNS:flags>#{@dnskey.flags}</secDNS:flags>
                <secDNS:protocol>#{@dnskey.protocol}</secDNS:protocol>
                <secDNS:alg>#{@dnskey.alg}</secDNS:alg>
                <secDNS:pubKey>#{@dnskey.public_key}</secDNS:pubKey>
              </secDNS:keyData>
            </secDNS:rem>
          </secDNS:update>
          </extension>
        </command>
      </epp>
    XML

    post epp_update_path, params: { frame: request_xml },
                          headers: { 'HTTP_COOKIE' => 'session=api_bestnames' }
    response_xml = Nokogiri::XML(response.body)
    assert_correct_against_schema response_xml
    @domain.reload
    assert_equal 0, @domain.dnskeys.count
    assert_epp_response :completed_successfully
  end

  def test_remove_dnskey_if_remove_all
    request_xml = <<-XML
      <?xml version="1.0" encoding="UTF-8" standalone="no"?>
      <epp xmlns="#{Xsd::Schema.filename(for_prefix: 'epp-ee', for_version: '1.0')}">
        <command>
          <update>
            <domain:update xmlns:domain="#{Xsd::Schema.filename(for_prefix: 'domain-ee', for_version: '1.2')}">
              <domain:name>shop.test</domain:name>
                <domain:chg>
                  <domain:authInfo>
                    <domain:pw>f0ff7d17b0</domain:pw>
                  </domain:authInfo>
                </domain:chg>
            </domain:update>
          </update>
          <extension>
          <secDNS:update xmlns:secDNS="urn:ietf:params:xml:ns:secDNS-1.1">
            <secDNS:rem>
              <secDNS:all>true</secDNS:all>
            </secDNS:rem>
          </secDNS:update>
          </extension>
        </command>
      </epp>
    XML

    post epp_update_path, params: { frame: request_xml },
         headers: { 'HTTP_COOKIE' => 'session=api_bestnames' }
    response_xml = Nokogiri::XML(response.body)
    assert_correct_against_schema response_xml
    @domain.reload
    assert_equal 0, @domain.dnskeys.count
    assert_epp_response :completed_successfully
  end

  def test_replace_dnskey_with_spaces_in_request
    doc = Nokogiri::XML::Document.parse(schema_new)
    params = { parsed_frame: doc }
    domain_controller = Epp::DomainsController.new
    domain_controller.params = ActionController::Parameters.new(params)

    assert_equal(domain_controller.send(:parsed_response_for_dnskey, 'rem'), true)
    assert_equal(domain_controller.send(:parsed_response_for_dnskey, 'add'), true)
  end

  def schema_new
    <<~XML
<?xml version=\"1.0\" encoding=\"utf-8\"?>
<epp schemaLocation=\"https://epp.tld.ee/schema/epp-ee-1.0.xsd epp-ee-1.0.xsd                          https://epp.tld.ee/schema/domain-ee-1.2.xsd domain-ee-1.2.xsd                          urn:ietf:params:xml:ns:secDNS-1.1 secDNS-1.1.xsd                          https://epp.tld.ee/schema/eis-1.0.xsd eis-1.0.xsd\">
    <command>
        <update>
            <update>
                <name>shop.test</name>
            </update>
        </update>
        <extension>
                <update>
                    <rem>         \n
                        <keyData>
                            <flags>257</flags>
                            <protocol>3</protocol>
                            <alg>8</alg>
                            <pubKey>AwEAAbXae59P87nfCP1MpLJouUhtDlVFbgek392nxqJcIHwYAs5sd4O4BPAvd41VmqhWllTiArNYDBV8UAtPZ8eZtYDC4D7ITC1HsxzQzzMUOorrNwMQMFq/PHP9tKelfRh68dh7UX0nTKlIouTcZ3xbqxAeoAbgvFjj/ZDS8G4QE2NgdonaK2w9q/da189zrZUhyAgecZCiTXbqqXd/LNXGRwDjJgFBWBmXbEjkcSfHke7idAcGqmYK2E5FstsmEwDcupxZ8jxuN1m/wDrBeZE5UdT24LtLGDda+ATXvCuARhQtZzSAn0JOdfGN5xJ02g+OtsbVC/mSGR3rykjzJ+hUlPU=</pubKey>\n                        </keyData>
                    </rem>
                    <add>         \n
                        <keyData>
                            <flags>257</flags>
                           <protocol>3</protocol>
                            <alg>8</alg>
                            <pubKey>AwEAAdas/oY6xQV2MYd+o5pcUHK0f/mtETRNyBhh/TSABqRM9JikXlSrwLFT9sAfOsTiRNbPnvEiCKdEdoN0f0Oel0WNXadLlVINmxtCue93bSX7zxrVvjhbkHffOVdpBL0CIDQoX1HPZmoBXXPdZtWLpDQ7nVfUtdC/McTFSRawUYaoCWOEAgC8YY+kh6C8TUZzHMl+JiVE6YFkTIFf+z4MxA920UxUnGpdcfRbcB0CYjCxe+PuiA+aZHFheEe5S5tlW7tO96hxK/k2l93N//T2mEM53TKomk62HoWvNVdPrs7jdZbGzeY2eBPDWMAIIpgOv9ApORi+kHSQm2POCwf/KYs=</pubKey>\n                        </keyData>
                    </add>
                </update>
        </extension>
    <clTRID>0.04946500 1632965705</clTRID>
    </command>
</epp>\n
    XML
  end
end
