require 'rails_helper'

RSpec.describe 'EPP domain:renew' do
  let(:user) { FactoryGirl.create(:api_user_epp, registrar: registrar) }
  let(:registrar) { FactoryGirl.create(:registrar) }
  subject(:response_xml) { Nokogiri::XML(response.body) }
  subject(:response_code) { response_xml.xpath('//xmlns:result').first['code'] }
  subject(:response_description) { response_xml.css('result msg').text }

  before :example do
    travel_to Time.zone.parse('05.07.2010')
    sign_in_to_epp_area(user: user)
    FactoryGirl.create(:account, registrar: registrar, balance: 1)
    Setting.days_to_renew_domain_before_expire = 0

    FactoryGirl.create(:pricelist,
                       category: 'com',
                       duration: '3years',
                       price: 1.to_money,
                       operation_category: 'renew',
                       valid_from: Time.zone.parse('05.07.2010'),
                       valid_to: Time.zone.parse('05.07.2010')
    )
  end

  context 'when domain can be renewed' do
    let!(:domain) { FactoryGirl.create(:domain,
                                       registrar: registrar,
                                       name: 'test.com',
                                       expire_time: Time.zone.parse('05.07.2010'))
    }
    let(:request_xml) { <<-XML
      <?xml version="1.0" encoding="UTF-8" standalone="no"?>
      <epp xmlns="https://epp.tld.ee/schema/epp-ee-1.0.xsd">
        <command>
          <renew>
            <domain:renew xmlns:domain="https://epp.tld.ee/schema/domain-eis-1.0.xsd">
              <domain:name>test.com</domain:name>
              <domain:curExpDate>2010-07-05</domain:curExpDate>
              <domain:period unit="y">3</domain:period>
            </domain:renew>
          </renew>
        </command>
      </epp>
    XML
    }

    it 'returns epp code of 1000' do
      post '/epp/command/renew', frame: request_xml
      expect(response_code).to eq('1000')
    end

    it 'returns epp description' do
      post '/epp/command/renew', frame: request_xml
      expect(response_description).to eq('Command completed successfully')
    end
  end

  context 'when domain cannot be renewed' do
    let!(:domain) { FactoryGirl.create(:domain,
                                       registrar: registrar,
                                       name: 'test.com',
                                       expire_time: Time.zone.parse('05.07.2011'))
    }
    let(:request_xml) { <<-XML
      <?xml version="1.0" encoding="UTF-8" standalone="no"?>
      <epp xmlns="https://epp.tld.ee/schema/epp-ee-1.0.xsd">
        <command>
          <renew>
            <domain:renew xmlns:domain="https://epp.tld.ee/schema/domain-eis-1.0.xsd">
              <domain:name>test.com</domain:name>
              <domain:curExpDate>2011-07-05</domain:curExpDate>
              <domain:period unit="y">3</domain:period>
            </domain:renew>
          </renew>
        </command>
      </epp>
    XML
    }

    it 'returns epp code of 2105' do
      post '/epp/command/renew', frame: request_xml
      expect(response_code).to eq('2105')
    end

    it 'returns epp description' do
      post '/epp/command/renew', frame: request_xml
      expect(response_description).to eq('Object is not eligible for renewal; ' \
        'Expiration date must be before 2014-07-05')
    end
  end
end
