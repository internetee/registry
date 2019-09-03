require 'rails_helper'

RSpec.describe 'EPP domain:renew', settings: false do
  let(:session_id) { create(:epp_session, user: user).session_id }
  let(:request) { post '/epp/command/renew', { frame: request_xml }, 'HTTP_COOKIE' => "session=#{session_id}" }
  let!(:user) { create(:api_user_epp, registrar: registrar) }
  let!(:zone) { create(:zone, origin: 'test') }
  let!(:registrar) { create(:registrar_with_unlimited_balance) }
  let!(:domain) { create(:domain,
                         registrar: registrar,
                         name: 'test.test',
                         expire_time: Time.zone.parse('05.07.2010 10:30'))
  }
  let(:request_xml) { <<-XML
    <?xml version="1.0" encoding="UTF-8" standalone="no"?>
    <epp xmlns="https://epp.tld.ee/schema/epp-ee-1.0.xsd">
      <command>
        <renew>
          <domain:renew xmlns:domain="https://epp.tld.ee/schema/domain-eis-1.0.xsd">
            <domain:name>test.test</domain:name>
            <domain:curExpDate>2010-07-05</domain:curExpDate>
            <domain:period unit="y">1</domain:period>
          </domain:renew>
        </renew>
      </command>
    </epp>
  XML
  }

  before :example do
    travel_to Time.zone.parse('05.07.2010')
    Setting.days_to_renew_domain_before_expire = 0
    sign_in user
  end

  context 'when price is present' do
    let!(:price) { create(:price,
                          duration: '1 year',
                          price: Money.from_amount(1),
                          operation_category: 'renew',
                          valid_from: Time.zone.parse('05.07.2010'),
                          valid_to: Time.zone.parse('05.07.2010'),
                          zone: zone)
    }

    it 'renews domain for 1 year' do
      request
      domain.reload
      expect(domain.expire_time).to eq(Time.zone.parse('05.07.2011 10:30'))
    end

    specify do
      request
      expect(Epp::Response.xml(response.body).code?(Epp::Response::Result::Code.key(:completed_successfully))).to be_truthy
    end
  end

  context 'when price is absent' do
    it 'does not renew domain' do
      expect { request; domain.reload }.to_not change { domain.expire_time }
    end

    specify do
      request
      expect(Epp::Response.xml(response.body).code?(Epp::Response::Result::Code.key(:billing_failure))).to be_truthy
    end
  end
end
