require 'test_helper'

class EppDomainUpdateReplaceDnsTest < EppTestCase
  def setup
    # Mock DNSValidator to return success
    @original_validate = DNSValidator.method(:validate)
    DNSValidator.define_singleton_method(:validate) { |**args| { errors: [] } }
  end
  
  def teardown
    # Restore original validate method
    DNSValidator.define_singleton_method(:validate, @original_validate)
  end
  
  def test_parsed_response_for_dnskey_with_spaces_in_request
    doc = Nokogiri::XML::Document.parse(schema_update)
    params = { parsed_frame: doc }
    domain_controller = Epp::DomainsController.new
    domain_controller.params = ActionController::Parameters.new(params)

    assert_equal(domain_controller.send(:parsed_response_for_dnskey, 'rem'), true)
    assert_equal(domain_controller.send(:parsed_response_for_dnskey, 'add'), true)
  end

  def schema_update
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
