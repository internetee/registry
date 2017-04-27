require 'rails_helper'

RSpec.describe 'EPP domain:create', settings: false do
  let(:request) { post '/epp/command/create', frame: request_xml }
  let!(:user) { create(:api_user_epp, registrar: registrar) }
  let!(:contact) { create(:contact, code: 'test') }
  let!(:zone) { create(:zone, origin: 'test') }
  let!(:registrar) { create(:registrar_with_unlimited_balance) }

  before :example do
    travel_to Time.zone.parse('05.07.2010 10:30')
    Setting.days_to_renew_domain_before_expire = 0
    sign_in_to_epp_area(user: user)
  end

  context 'when period is 3 months' do
    let!(:price) { create(:price,
                          duration: '3 mons',
                          price: Money.from_amount(1),
                          operation_category: 'create',
                          valid_from: Time.zone.parse('05.07.2010'),
                          valid_to: Time.zone.parse('05.07.2010'),
                          zone: zone)
    }
    let(:request_xml) { <<-XML
      <?xml version="1.0" encoding="UTF-8" standalone="no"?>
      <epp xmlns="https://epp.tld.ee/schema/epp-ee-1.0.xsd">
        <command>
          <create>
            <domain:create xmlns:domain="https://epp.tld.ee/schema/domain-eis-1.0.xsd">
              <domain:name>test.test</domain:name>
              <domain:period unit="m">3</domain:period>
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


    it 'creates domain' do
      expect { request }.to change { Domain.count }.from(0).to(1)
    end

    specify 'expire_time' do
      request
      expire_time = (Time.zone.parse('05.07.2010 10:30') + 3.months + 1.day).beginning_of_day
      expect(Domain.first.expire_time).to eq(expire_time)
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
                          operation_category: 'create',
                          valid_from: Time.zone.parse('05.07.2010'),
                          valid_to: Time.zone.parse('05.07.2010'),
                          zone: zone)
    }
    let(:request_xml) { <<-XML
      <?xml version="1.0" encoding="UTF-8" standalone="no"?>
      <epp xmlns="https://epp.tld.ee/schema/epp-ee-1.0.xsd">
        <command>
          <create>
            <domain:create xmlns:domain="https://epp.tld.ee/schema/domain-eis-1.0.xsd">
              <domain:name>test.test</domain:name>
              <domain:period unit="y">10</domain:period>
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

    it 'creates domain' do
      expect { request }.to change { Domain.count }.from(0).to(1)
    end

    specify 'expire_time' do
      request
      expire_time = (Time.zone.parse('05.07.2010 10:30') + 10.years + 1.day).beginning_of_day
      expect(Domain.first.expire_time).to eq(expire_time)
    end

    specify do
      request
      expect(response).to have_code_of(1000)
    end
  end
end
