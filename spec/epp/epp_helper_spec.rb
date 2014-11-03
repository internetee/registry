require 'rails_helper'

describe 'EPP Helper', epp: true do
  context 'in context of Domain' do
    it 'generates valid renew xml' do
      expected = Nokogiri::XML('<?xml version="1.0" encoding="UTF-8" standalone="no"?>
        <epp xmlns="urn:ietf:params:xml:ns:epp-1.0">
          <command>
            <renew>
              <domain:renew
               xmlns:domain="urn:ietf:params:xml:ns:domain-1.0">
                <domain:name>example.ee</domain:name>
                <domain:curExpDate>2014-08-07</domain:curExpDate>
                <domain:period unit="y">1</domain:period>
              </domain:renew>
            </renew>
            <clTRID>ABC-12345</clTRID>
          </command>
        </epp>
      ').to_s.squish

      generated = Nokogiri::XML(domain_renew_xml).to_s.squish
      expect(generated).to eq(expected)

      expected = Nokogiri::XML('<?xml version="1.0" encoding="UTF-8" standalone="no"?>
        <epp xmlns="urn:ietf:params:xml:ns:epp-1.0">
          <command>
            <renew>
              <domain:renew
               xmlns:domain="urn:ietf:params:xml:ns:domain-1.0">
                <domain:name>one.ee</domain:name>
                <domain:curExpDate>2009-11-15</domain:curExpDate>
                <domain:period unit="d">365</domain:period>
              </domain:renew>
            </renew>
            <clTRID>ABC-12345</clTRID>
          </command>
        </epp>
      ').to_s.squish

      generated = Nokogiri::XML(domain_renew_xml(name: 'one.ee', curExpDate: '2009-11-15',
                                                 period_value: '365', period_unit: 'd')).to_s.squish
      expect(generated).to eq(expected)
    end

    it 'generates valid transfer xml' do
      expected = Nokogiri::XML('<?xml version="1.0" encoding="UTF-8" standalone="no"?>
        <epp xmlns="urn:ietf:params:xml:ns:epp-1.0">
          <command>
            <transfer op="query">
              <domain:transfer
               xmlns:domain="urn:ietf:params:xml:ns:domain-1.0">
                <domain:name>example.ee</domain:name>
                <domain:authInfo>
                  <domain:pw roid="JD1234-REP">98oiewslkfkd</domain:pw>
                </domain:authInfo>
              </domain:transfer>
            </transfer>
            <clTRID>ABC-12345</clTRID>
          </command>
        </epp>
      ').to_s.squish

      generated = Nokogiri::XML(domain_transfer_xml).to_s.squish
      expect(generated).to eq(expected)

      expected = Nokogiri::XML('<?xml version="1.0" encoding="UTF-8" standalone="no"?>
        <epp xmlns="urn:ietf:params:xml:ns:epp-1.0">
          <command>
            <transfer op="approve">
              <domain:transfer
               xmlns:domain="urn:ietf:params:xml:ns:domain-1.0">
                <domain:name>one.ee</domain:name>
                <domain:authInfo>
                  <domain:pw roid="askdf">test</domain:pw>
                </domain:authInfo>
              </domain:transfer>
            </transfer>
            <clTRID>ABC-12345</clTRID>
          </command>
        </epp>
      ').to_s.squish

      xml = domain_transfer_xml(name: 'one.ee', op: 'approve', pw: 'test', roid: 'askdf')

      generated = Nokogiri::XML(xml).to_s.squish
      expect(generated).to eq(expected)
    end
  end
end
