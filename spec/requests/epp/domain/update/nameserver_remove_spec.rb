require 'rails_helper'

RSpec.describe 'EPP domain:update' do
  let(:registrar) { create(:registrar) }
  let(:user) { create(:api_user_epp, registrar: registrar) }
  let(:session_id) { create(:epp_session, user: user, registrar: registrar).session_id }
  subject(:response_xml) { Nokogiri::XML(response.body) }
  subject(:response_code) { response_xml.xpath('//xmlns:result').first['code'] }
  subject(:response_description) { response_xml.css('result msg').text }

  before :example do
    login_as user
    allow(Domain).to receive(:nameserver_required?).and_return(false)
  end

  context 'when remaining nameserver count is less than required minimum' do
    let!(:domain) { create(:domain, name: 'test.com') }
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
        </command>
      </epp>
    XML
    }

    before :example do
      Setting.ns_min_count = 2
      Setting.ns_max_count = 3

      domain.nameservers << create(:nameserver, hostname: 'ns1.test.ee')
      domain.nameservers << create(:nameserver, hostname: 'ns2.test.ee')
    end

    it 'returns epp code of 2308' do
      post '/epp/command/update', { frame: request_xml }, 'HTTP_COOKIE' => "session=#{session_id}"
      expect(response_code).to eq('2308'), "Expected EPP code of 2308, got #{response_code} (#{response_description})"
    end

    it 'returns epp description' do
      post '/epp/command/update', { frame: request_xml }, 'HTTP_COOKIE' => "session=#{session_id}"

      description = 'Data management policy violation;' \
      " Nameserver count must be between #{Setting.ns_min_count}-#{Setting.ns_max_count}" \
      ' for active domains [nameservers]'
      expect(response_description).to eq(description)
    end
  end

  context 'when all nameservers are removed' do
    let!(:domain) { create(:domain, name: 'test.com') }
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
        </command>
      </epp>
    XML
    }

    before :example do
      domain.nameservers << create(:nameserver, hostname: 'ns1.test.ee')
      domain.nameservers << create(:nameserver, hostname: 'ns2.test.ee')
      domain.activate
      domain.save!
    end

    it 'returns epp code of 1000' do
      post '/epp/command/update', { frame: request_xml }, 'HTTP_COOKIE' => "session=#{session_id}"
      expect(response_code).to eq('1000'), "Expected EPP code of 1000, got #{response_code} (#{response_description})"
    end

    describe 'domain' do
      it 'has status of inactive' do
        post '/epp/command/update', { frame: request_xml }, 'HTTP_COOKIE' => "session=#{session_id}"
        domain = Domain.find_by(name: 'test.com')
        expect(domain.statuses).to include(DomainStatus::INACTIVE)
      end
    end
  end
end
