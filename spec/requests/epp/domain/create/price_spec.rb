require 'rails_helper'

RSpec.describe 'EPP domain:create', settings: false do
  let(:session_id) { create(:epp_session, user: user, registrar: registrar).session_id }
  let(:request) { post '/epp/command/create', { frame: request_xml }, 'HTTP_COOKIE' => "session=#{session_id}" }
  let!(:user) { create(:api_user_epp, registrar: registrar) }
  let!(:contact) { create(:contact, code: 'test') }
  let!(:zone) { create(:zone, origin: 'test') }
  let!(:registrar) { create(:registrar_with_unlimited_balance) }
  let(:request_xml) { <<-XML
    <?xml version="1.0" encoding="UTF-8" standalone="no"?>
    <epp xmlns="https://epp.tld.ee/schema/epp-ee-1.0.xsd">
      <command>
        <create>
          <domain:create xmlns:domain="https://epp.tld.ee/schema/domain-eis-1.0.xsd">
            <domain:name>test.test</domain:name>
            <domain:period unit="y">1</domain:period>
            <domain:registrant>test</domain:registrant>
          </domain:create>
        </create>
        <extension>
          <eis:extdata xmlns:eis="https://epp.tld.ee/schema/eis-1.0.xsd">
            <eis:legalDocument type="pdf">#{valid_legal_document}</eis:legalDocument>
          </eis:extdata>
        </extension>
      </command>
    </epp>
  XML
  }

  before :example do
    travel_to Time.zone.parse('05.07.2010')
    Setting.days_to_renew_domain_before_expire = 0
    login_as user
  end

  context 'when price is present' do
    let!(:price) { create(:price,
                          duration: '1 year',
                          price: Money.from_amount(1),
                          operation_category: 'create',
                          valid_from: Time.zone.parse('05.07.2010'),
                          valid_to: Time.zone.parse('05.07.2010'),
                          zone: zone)
    }

    it 'creates domain' do
      expect { request }.to change { Domain.count }.from(0).to(1)
    end

    specify do
      request
      expect(response).to have_code_of(1000)
    end
  end

  context 'when price is absent' do
    it 'does not create domain' do
      expect { request }.to_not change { Domain.count }
    end

    specify do
      request
      expect(response).to have_code_of(2104)
    end
  end
end
