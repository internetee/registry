require 'rails_helper'

RSpec.describe 'EPP domain:update' do
  let!(:domain) { create(:domain, name: 'test.com') }
  subject(:response_xml) { Nokogiri::XML(response.body) }
  subject(:response_code) { response_xml.xpath('//xmlns:result').first['code'] }
  subject(:response_description) { response_xml.css('result msg').text }

  before :example do
    sign_in_to_epp_area

    allow(Domain).to receive(:nameserver_required?).and_return(false)
    Setting.ns_min_count = 2
    Setting.ns_max_count = 3
  end

  describe 'nameserver add' do
    context 'when nameserver count is less than minimum' do
      let(:request_xml) { <<-XML
        <?xml version="1.0" encoding="UTF-8" standalone="no"?>
        <epp xmlns="https://epp.tld.ee/schema/epp-ee-1.0.xsd">
          <command>
            <update>
              <domain:update xmlns:domain="https://epp.tld.ee/schema/domain-eis-1.0.xsd">
                <domain:name>test.com</domain:name>
                <domain:add>
                  <domain:ns>
                    <domain:hostAttr>
                      <domain:hostName>ns1.test.ee</domain:hostName>
                    </domain:hostAttr>
                  </domain:ns>
                </domain:add>
              </domain:update>
            </update>
            <extension>
              <secDNS:update xmlns:secDNS="urn:ietf:params:xml:ns:secDNS-1.1"/>
              <eis:extdata xmlns:eis="https://epp.tld.ee/schema/eis-1.0.xsd">
                <eis:legalDocument type="pdf">#{Base64.encode64('a' * 5000)}</eis:legalDocument>
              </eis:extdata>
            </extension>
          </command>
        </epp>
      XML
      }

      it 'returns epp code of 2308' do
        post '/epp/command/update', frame: request_xml
        expect(response_code).to eq('2308'), "Expected EPP code of 2308, got #{response_code} (#{response_description})"
      end

      it 'returns epp description' do
        post '/epp/command/update', frame: request_xml

        description = 'Data management policy violation;' \
        " Nameserver count must be between #{Setting.ns_min_count}-#{Setting.ns_max_count}" \
        ' for active domains [nameservers]'
        expect(response_description).to eq(description)
      end
    end

    context 'when nameserver count satisfies required minimum' do
      let!(:domain) { create(:domain, name: 'test.com') }
      let(:request_xml) { <<-XML
        <?xml version="1.0" encoding="UTF-8" standalone="no"?>
        <epp xmlns="https://epp.tld.ee/schema/epp-ee-1.0.xsd">
          <command>
            <update>
              <domain:update xmlns:domain="https://epp.tld.ee/schema/domain-eis-1.0.xsd">
                <domain:name>test.com</domain:name>
                <domain:add>
                  <domain:ns>
                    <domain:hostAttr>
                      <domain:hostName>ns1.test.ee</domain:hostName>
                    </domain:hostAttr>                    
                    <domain:hostAttr>
                      <domain:hostName>ns2.test.ee</domain:hostName>
                    </domain:hostAttr>
                  </domain:ns>
                </domain:add>
              </domain:update>
            </update>
            <extension>
              <secDNS:update xmlns:secDNS="urn:ietf:params:xml:ns:secDNS-1.1"/>
              <eis:extdata xmlns:eis="https://epp.tld.ee/schema/eis-1.0.xsd">
                <eis:legalDocument type="pdf">#{Base64.encode64('a' * 5000)}</eis:legalDocument>
              </eis:extdata>
            </extension>
          </command>
        </epp>
      XML
      }

      it 'returns epp code of 1000' do
        post '/epp/command/update', frame: request_xml
        expect(response_code).to eq('1000'), "Expected EPP code of 1000, got #{response_code} (#{response_description})"
      end

      it 'removes inactive status' do
        post '/epp/command/update', frame: request_xml

        domain = Domain.find_by(name: 'test.com')
        expect(domain.statuses).to_not include(DomainStatus::INACTIVE)
      end
    end
  end

  describe 'nameserver remove' do
    before :example do
      domain.nameservers << create(:nameserver, hostname: 'ns1.test.ee')
      domain.nameservers << create(:nameserver, hostname: 'ns2.test.ee')
    end

    context 'when nameserver count is less than minimum' do
      let(:request_xml) { <<-XML
        <?xml version="1.0" encoding="UTF-8" standalone="no"?>
        <epp xmlns="https://epp.tld.ee/schema/epp-ee-1.0.xsd">
          <command>
            <update>
              <domain:update xmlns:domain="https://epp.tld.ee/schema/domain-eis-1.0.xsd">
                <domain:name>test.com</domain:name>
                <domain:rem>
                  <domain:ns>
                    <domain:hostAttr>
                      <domain:hostName>ns1.test.ee</domain:hostName>
                    </domain:hostAttr>
                  </domain:ns>
                </domain:rem>
              </domain:update>
            </update>
            <extension>
              <secDNS:update xmlns:secDNS="urn:ietf:params:xml:ns:secDNS-1.1"/>
              <eis:extdata xmlns:eis="https://epp.tld.ee/schema/eis-1.0.xsd">
                <eis:legalDocument type="pdf">#{Base64.encode64('a' * 5000)}</eis:legalDocument>
              </eis:extdata>
            </extension>
          </command>
        </epp>
      XML
      }

      it 'returns epp code of 2308' do
        post '/epp/command/update', frame: request_xml
        expect(response_code).to eq('2308'), "Expected EPP code of 2308, got #{response_code} (#{response_description})"
      end

      it 'returns epp description' do
        post '/epp/command/update', frame: request_xml

        description = 'Data management policy violation;' \
      " Nameserver count must be between #{Setting.ns_min_count}-#{Setting.ns_max_count}" \
      ' for active domains [nameservers]'
        expect(response_description).to eq(description)
      end
    end

    context 'when all nameservers are removed' do
      let(:request_xml) { <<-XML
        <?xml version="1.0" encoding="UTF-8" standalone="no"?>
        <epp xmlns="https://epp.tld.ee/schema/epp-ee-1.0.xsd">
          <command>
            <update>
              <domain:update xmlns:domain="https://epp.tld.ee/schema/domain-eis-1.0.xsd">
                <domain:name>test.com</domain:name>
                <domain:rem>
                  <domain:ns>
                    <domain:hostAttr>
                      <domain:hostName>ns1.test.ee</domain:hostName>
                    </domain:hostAttr>
                    <domain:hostAttr>
                      <domain:hostName>ns2.test.ee</domain:hostName>
                    </domain:hostAttr>
                  </domain:ns>
                </domain:rem>
              </domain:update>
            </update>
            <extension>
              <secDNS:update xmlns:secDNS="urn:ietf:params:xml:ns:secDNS-1.1"/>
              <eis:extdata xmlns:eis="https://epp.tld.ee/schema/eis-1.0.xsd">
                <eis:legalDocument type="pdf">#{Base64.encode64('a' * 5000)}</eis:legalDocument>
              </eis:extdata>
            </extension>
          </command>
        </epp>
      XML
      }

      it 'returns epp code of 1000' do
        post '/epp/command/update', frame: request_xml
        expect(response_code).to eq('2308'), "Expected EPP code of 1000, got #{response_code} (#{response_description})"
      end
    end
  end
end
