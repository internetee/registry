require 'rails_helper'

RSpec.describe 'EPP contact:delete' do
  let(:session_id) { create(:epp_session, user: user).session_id }
  let(:user) { create(:api_user, registrar: registrar) }
  let(:registrar) { create(:registrar) }
  let!(:registrant) { create(:registrant, registrar: registrar, code: 'TEST') }
  let(:request) { post '/epp/command/delete', { frame: request_xml }, 'HTTP_COOKIE' => "session=#{session_id}" }
  let(:request_xml) { <<-XML
    <?xml version="1.0" encoding="UTF-8" standalone="no"?>
    <epp xmlns="https://epp.tld.ee/schema/epp-ee-1.0.xsd">
      <command>
        <delete>
          <contact:delete xmlns:contact="https://epp.tld.ee/schema/contact-ee-1.1.xsd">
            <contact:id>test</contact:id>
          </contact:delete>
        </delete>
      </command>
    </epp>
  XML
  }

  before do
    sign_in user
  end

  context 'when contact is used' do
    let!(:domain) { create(:domain, registrant: registrant) }

    specify do
      request
      expect(response).to have_code_of(2305)
    end

    it 'does not delete contact' do
      expect { request }.to_not change { Contact.count }
    end
  end

  context 'when contact is not used' do
    specify do
      request
      expect(response).to have_code_of(1000)
    end

    it 'deletes contact' do
      expect { request }.to change { Contact.count }.from(1).to(0)
    end
  end
end
