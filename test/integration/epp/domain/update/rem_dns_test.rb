require 'test_helper'

class EppDomainUpdateRemDnsTest < EppTestCase
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
    Spy.on_instance_method(ValidateDnssec, :validate_dnssec).and_return(true)
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
end
