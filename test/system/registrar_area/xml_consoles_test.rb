require 'application_system_test_case'

class RegistrarAreaXmlConsolesTest < ApplicationSystemTestCase
  setup do
    sign_in users(:api_bestnames)
  end

  def test_epp_server_does_not_response
    visit registrar_xml_console_path
    fill_in 'payload', with: schema_example
    click_on 'Send EPP Request'

    el = page.find('.CodeRay', visible: :all)
    assert el.text.include? 'CONNECTION ERROR - Is the EPP server running?'
  end

  def test_update_dnskey
    @domain = domains(:shop)
    @dnskey = dnskeys(:one)
    @dnskeynew = dnskeys(:two)
    visit registrar_xml_console_path
    fill_in 'payload', with: schema_dnskey_rem(@dnskey)
    click_on 'Send EPP Request'
    fill_in 'payload', with: schema_dnskey_rem(@dnskeynew)
    click_on 'Send EPP Request'

    visit registrar_xml_console_path
    fill_in 'payload', with: schema_dnskey_add
    click_on 'Send EPP Request'

    el = page.find('.CodeRay', visible: :all)
    assert el.text.include? 'Command completed successfully'

    @domain.statuses << DomainStatus::SERVER_UPDATE_PROHIBITED
    assert @domain.statuses.include? DomainStatus::SERVER_UPDATE_PROHIBITED

    ENV['obj_and_extensions_prohibited'] = 'true'
    assert Feature.obj_and_extensions_statuses_enabled?

    visit registrar_xml_console_path
    fill_in 'payload', with: schema_dnskey_update
    click_on 'Send EPP Request'

    el = page.find('.CodeRay', visible: :all)
    assert el.text.include? 'Command completed successfully'
  end

  private

  def schema_dnskey_rem(key)
    <<~XML
<?xml version="1.0" encoding="utf-8"?>
<epp xmlns="https://epp.tld.ee/schema/epp-ee-1.0.xsd" xmlns:domain="https://epp.tld.ee/schema/domain-ee-1.2.xsd" xmlns:secDNS="urn:ietf:params:xml:ns:secDNS-1.1" xmlns:eis="https://epp.tld.ee/schema/eis-1.0.xsd" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xsi:schemaLocation="https://epp.tld.ee/schema/epp-ee-1.0.xsd epp-ee-1.0.xsd                          https://epp.tld.ee/schema/domain-ee-1.2.xsd domain-ee-1.2.xsd                          urn:ietf:params:xml:ns:secDNS-1.1 secDNS-1.1.xsd                          https://epp.tld.ee/schema/eis-1.0.xsd eis-1.0.xsd">
    <command>
        <update>
            <domain:update>
                <domain:name>shop.test</domain:name>
            </domain:update>
        </update>
        <extension>
                <secDNS:update>
                    <secDNS:rem>
                        <secDNS:keyData>
                            <secDNS:flags>#{key.flags}</secDNS:flags>
                            <secDNS:protocol>#{key.protocol}</secDNS:protocol>
                            <secDNS:alg>#{key.alg}</secDNS:alg>
                            <secDNS:pubKey>#{key.public_key}</secDNS:pubKey>
                        </secDNS:keyData>
                    </secDNS:rem>
                </secDNS:update>
        </extension>
    <clTRID>0.04946500 1632965705</clTRID>
    </command>
</epp>
    XML
  end

  def schema_dnskey_add
    <<~XML
<?xml version="1.0" encoding="utf-8"?>
<epp xmlns="https://epp.tld.ee/schema/epp-ee-1.0.xsd" xmlns:domain="https://epp.tld.ee/schema/domain-ee-1.2.xsd" xmlns:secDNS="urn:ietf:params:xml:ns:secDNS-1.1" xmlns:eis="https://epp.tld.ee/schema/eis-1.0.xsd" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xsi:schemaLocation="https://epp.tld.ee/schema/epp-ee-1.0.xsd epp-ee-1.0.xsd                          https://epp.tld.ee/schema/domain-ee-1.2.xsd domain-ee-1.2.xsd                          urn:ietf:params:xml:ns:secDNS-1.1 secDNS-1.1.xsd                          https://epp.tld.ee/schema/eis-1.0.xsd eis-1.0.xsd">
    <command>
        <update>
            <domain:update>
                <domain:name>shop.test</domain:name>
            </domain:update>
        </update>
        <extension>
                <secDNS:update>
                    <secDNS:add>
                        <secDNS:keyData>
                            <secDNS:flags>#{@dnskey.flags}</secDNS:flags>
                            <secDNS:protocol>#{@dnskey.protocol}</secDNS:protocol>
                            <secDNS:alg>#{@dnskey.alg}</secDNS:alg>
                            <secDNS:pubKey>#{@dnskey.public_key}</secDNS:pubKey>
                        </secDNS:keyData>
                    </secDNS:add>
                </secDNS:update>
        </extension>
    <clTRID>0.04946500 1632965705</clTRID>
    </command>
</epp>
    XML
  end

  def schema_dnskey_update
    @dnskey = dnskeys(:one)
    @dnskeynew = dnskeys(:two)
    <<~XML
<?xml version="1.0" encoding="utf-8"?>
<epp xmlns="https://epp.tld.ee/schema/epp-ee-1.0.xsd" xmlns:domain="https://epp.tld.ee/schema/domain-ee-1.2.xsd" xmlns:secDNS="urn:ietf:params:xml:ns:secDNS-1.1" xmlns:eis="https://epp.tld.ee/schema/eis-1.0.xsd" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xsi:schemaLocation="https://epp.tld.ee/schema/epp-ee-1.0.xsd epp-ee-1.0.xsd                          https://epp.tld.ee/schema/domain-ee-1.2.xsd domain-ee-1.2.xsd                          urn:ietf:params:xml:ns:secDNS-1.1 secDNS-1.1.xsd                          https://epp.tld.ee/schema/eis-1.0.xsd eis-1.0.xsd">
    <command>
        <update>
            <domain:update>
                <domain:name>shop.test</domain:name>
            </domain:update>
        </update>
        <extension>
                <secDNS:update>
                    <secDNS:rem>         \n
                        <secDNS:keyData>
                            <secDNS:flags>#{@dnskey.flags}</secDNS:flags>
                            <secDNS:protocol>#{@dnskey.protocol}</secDNS:protocol>
                            <secDNS:alg>#{@dnskey.alg}</secDNS:alg>
                            <secDNS:pubKey>#{@dnskey.public_key}</secDNS:pubKey>
                        </secDNS:keyData>         \n
                    </secDNS:rem>
                    <secDNS:add>         \n
                        <secDNS:keyData>
                            <secDNS:flags>#{@dnskeynew.flags}</secDNS:flags>
                            <secDNS:protocol>#{@dnskeynew.protocol}</secDNS:protocol>
                            <secDNS:alg>#{@dnskeynew.alg}</secDNS:alg>
                            <secDNS:pubKey>#{@dnskeynew.public_key}</secDNS:pubKey>
                        </secDNS:keyData>         \n
                    </secDNS:add>
                </secDNS:update>
        </extension>
    <clTRID>0.04946500 1632965705</clTRID>
    </command>
</epp>
    XML
  end

  def schema_example
    <<~XML
      <?xml version="1.0" encoding="UTF-8" standalone="no"?>
      <epp xmlns="https://epp.tld.ee/schema/epp-ee-1.0.xsd">
        <command>
          <check>
            <domain:check xmlns:domain="https://epp.tld.ee/schema/domain-ee-1.2.xsd">
              <domain:name>auction.test</domain:name>
            </domain:check>
          </check>
        </command>
      </epp>
    XML
  end
end
