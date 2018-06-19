require 'rails_helper'

RSpec.describe 'EPP domain:renew' do
  let(:session_id) { create(:epp_session, user: user).session_id }
  let(:user) { create(:api_user_epp, registrar: registrar) }
  let(:registrar) { create(:registrar_with_unlimited_balance) }
  let!(:zone) { create(:zone, origin: 'test') }
  let!(:price) { create(:price,
                        duration: '10 years',
                        price: Money.from_amount(1),
                        operation_category: 'renew',
                        valid_from: Time.zone.parse('05.07.2010'),
                        valid_to: Time.zone.parse('05.07.2010'),
                        zone: zone)
  }
  subject(:response_xml) { Nokogiri::XML(response.body) }
  subject(:response_code) { response_xml.xpath('//xmlns:result').first['code'] }
  subject(:response_description) { response_xml.css('result msg').text }

  before :example do
    travel_to Time.zone.parse('05.07.2010')
    Setting.days_to_renew_domain_before_expire = 0
    sign_in user
  end

  context 'when domain can be renewed' do
    let!(:domain) { create(:domain,
                           registrar: registrar,
                           name: 'test.test',
                           expire_time: Time.zone.parse('05.07.2010'))
    }
    let(:request_xml) { <<-XML
      <?xml version="1.0" encoding="UTF-8" standalone="no"?>
      <epp xmlns="https://epp.tld.ee/schema/epp-ee-1.0.xsd">
        <command>
          <renew>
            <domain:renew xmlns:domain="https://epp.tld.ee/schema/domain-eis-1.0.xsd">
              <domain:name>test.test</domain:name>
              <domain:curExpDate>2010-07-05</domain:curExpDate>
              <domain:period unit="y">10</domain:period>
            </domain:renew>
          </renew>
        </command>
      </epp>
    XML
    }

    it 'returns epp code of 1000' do
      post '/epp/command/renew', { frame: request_xml }, 'HTTP_COOKIE' => "session=#{session_id}"
      expect(response_code).to eq('1000')
    end

    it 'returns epp description' do
      post '/epp/command/renew', { frame: request_xml }, 'HTTP_COOKIE' => "session=#{session_id}"
      expect(response_description).to eq('Command completed successfully')
    end
  end

  context 'when domain cannot be renewed' do
    let!(:domain) { create(:domain,
                           registrar: registrar,
                           name: 'test.test',
                           expire_time: Time.zone.parse('05.07.2011'))
    }
    let(:request_xml) { <<-XML
      <?xml version="1.0" encoding="UTF-8" standalone="no"?>
      <epp xmlns="https://epp.tld.ee/schema/epp-ee-1.0.xsd">
        <command>
          <renew>
            <domain:renew xmlns:domain="https://epp.tld.ee/schema/domain-eis-1.0.xsd">
              <domain:name>test.test</domain:name>
              <domain:curExpDate>2011-07-05</domain:curExpDate>
              <domain:period unit="y">10</domain:period>
            </domain:renew>
          </renew>
        </command>
      </epp>
    XML
    }

    it 'returns epp code of 2105' do
      post '/epp/command/renew', { frame: request_xml }, 'HTTP_COOKIE' => "session=#{session_id}"
      expect(response_code).to eq('2105')
    end

    it 'returns epp description' do
      post '/epp/command/renew', { frame: request_xml }, 'HTTP_COOKIE' => "session=#{session_id}"
      expect(response_description).to eq('Object is not eligible for renewal; ' \
        'Expiration date must be before 2021-07-05')
    end
  end
end
