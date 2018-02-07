require 'rails_helper'

RSpec.describe 'EPP domain:renew', settings: false do
  let(:session_id) { create(:epp_session, user: user, registrar: registrar).session_id }
  let(:request) { post '/epp/command/renew', { frame: request_xml }, 'HTTP_COOKIE' => "session=#{session_id}" }
  let!(:user) { create(:api_user_epp, registrar: registrar) }
  let!(:zone) { create(:zone, origin: 'test') }
  let!(:registrar) { create(:registrar_with_unlimited_balance) }
  let!(:domain) { create(:domain,
                         registrar: registrar,
                         name: 'test.test',
                         expire_time: Time.zone.parse('05.07.2010 10:30'))
  }

  before :example do
    travel_to Time.zone.parse('05.07.2010')
    Setting.days_to_renew_domain_before_expire = 0
    login_as user
  end

  context 'when period is 3 months' do
    let!(:price) { create(:price,
                          duration: '3 mons',
                          price: Money.from_amount(1),
                          operation_category: 'renew',
                          valid_from: Time.zone.parse('05.07.2010'),
                          valid_to: Time.zone.parse('05.07.2010'),
                          zone: zone)
    }
    let(:request_xml) { <<-XML
      <?xml version="1.0" encoding="UTF-8" standalone="no"?>
      <epp xmlns="https://epp.tld.ee/schema/epp-ee-1.0.xsd">
        <command>
          <renew>
            <domain:renew xmlns:domain="https://epp.tld.ee/schema/domain-eis-1.0.xsd">
              <domain:name>test.test</domain:name>
              <domain:curExpDate>2010-07-05</domain:curExpDate>
              <domain:period unit="m">3</domain:period>
            </domain:renew>
          </renew>
        </command>
      </epp>
    XML
    }

    it 'renews domain for 3 months' do
      request
      domain.reload
      expect(domain.expire_time).to eq(Time.zone.parse('05.10.2010 10:30'))
    end

    specify do
      request
      expect(response).to have_code_of(1000)
    end
  end

  context 'when period is 10 years' do
    let!(:price) { create(:price,
                          duration: '10 years',
                          price: Money.from_amount(1),
                          operation_category: 'renew',
                          valid_from: Time.zone.parse('05.07.2010'),
                          valid_to: Time.zone.parse('05.07.2010'),
                          zone: zone)
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

    it 'renews domain for 10 years' do
      request
      domain.reload
      expect(domain.expire_time).to eq(Time.zone.parse('05.07.2020 10:30'))
    end

    specify do
      request
      expect(response).to have_code_of(1000)
    end
  end
end
