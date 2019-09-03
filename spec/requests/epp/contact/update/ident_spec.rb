require 'rails_helper'

# https://github.com/internetee/registry/issues/576

RSpec.describe 'EPP contact:update' do
  let(:registrar) { create(:registrar) }
  let(:user) { create(:api_user_epp, registrar: registrar) }
  let(:session_id) { create(:epp_session, user: user).session_id }
  let(:ident) { contact.identifier }
  let(:request) { post '/epp/command/update', { frame: request_xml }, 'HTTP_COOKIE' => "session=#{session_id}" }
  let(:request_xml) { <<-XML
    <?xml version="1.0" encoding="UTF-8" standalone="no"?>
    <epp xmlns="https://epp.tld.ee/schema/epp-ee-1.0.xsd">
      <command>
        <update>
          <contact:update xmlns:contact="https://epp.tld.ee/schema/contact-ee-1.1.xsd">
            <contact:id>TEST</contact:id>
            <contact:chg>
              <contact:postalInfo>
                <contact:name>test</contact:name>
              </contact:postalInfo>
            </contact:chg>
          </contact:update>
        </update>
        <extension>
          <eis:extdata xmlns:eis="https://epp.tld.ee/schema/eis-1.0.xsd">
            <eis:ident cc="US" type="priv">test</eis:ident>
          </eis:extdata>
        </extension>
      </command>
    </epp>
  XML
  }

  before do
    sign_in user
  end

  context 'when contact ident is valid' do
    context 'when submitted ident matches current one' do
      let!(:contact) { create(:contact, code: 'TEST',
                              ident: 'test',
                              ident_type: 'priv',
                              ident_country_code: 'US') }

      specify do
        request
        expect(Epp::Response.xml(response.body).code?(Epp::Response::Result::Code.key(:completed_successfully))).to be_truthy
      end
    end

    context 'when submitted ident does not match current one' do
      let!(:contact) { create(:contact, code: 'TEST',
                              ident: 'another-test',
                              ident_type: 'priv',
                              ident_country_code: 'US') }

      it 'does not update code' do
        expect do
          request
          contact.reload
        end.to_not change { ident.code }
      end

      it 'does not update type' do
        expect do
          request
          contact.reload
        end.to_not change { ident.type }
      end

      it 'does not update country code' do
        expect do
          request
          contact.reload
        end.to_not change { ident.country_code }
      end

      specify do
        request
        expect(Epp::Response.xml(response.body).code?(Epp::Response::Result::Code.key(:data_management_policy_violation))).to be_truthy
      end
    end
  end

  context 'when contact ident is invalid' do
    let(:contact) { build(:contact, code: 'TEST', ident: 'test', ident_type: nil, ident_country_code: nil) }

    before do
      contact.save(validate: false)
    end

    context 'when submitted ident is the same as current one' do
      let(:request_xml) { <<-XML
        <?xml version="1.0" encoding="UTF-8" standalone="no"?>
        <epp xmlns="https://epp.tld.ee/schema/epp-ee-1.0.xsd">
          <command>
            <update>
              <contact:update xmlns:contact="https://epp.tld.ee/schema/contact-ee-1.1.xsd">
                <contact:id>TEST</contact:id>
                <contact:chg>
                  <contact:postalInfo>
                    <contact:name>test</contact:name>
                  </contact:postalInfo>
                </contact:chg>
              </contact:update>
            </update>
            <extension>
              <eis:extdata xmlns:eis="https://epp.tld.ee/schema/eis-1.0.xsd">
                <eis:ident cc="US" type="priv">test</eis:ident>
              </eis:extdata>
            </extension>
          </command>
        </epp>
      XML
      }

      it 'does not update code' do
        expect do
          request
          contact.reload
        end.to_not change { ident.code }
      end

      it 'updates type' do
        request
        contact.reload
        expect(ident.type).to eq('priv')
      end

      it 'updates country code' do
        request
        contact.reload
        expect(ident.country_code).to eq('US')
      end

      specify do
        request
        expect(Epp::Response.xml(response.body).code?(Epp::Response::Result::Code.key(:completed_successfully))).to be_truthy
      end
    end

    context 'when submitted ident is different from current one' do
      let(:request_xml) { <<-XML
        <?xml version="1.0" encoding="UTF-8" standalone="no"?>
        <epp xmlns="https://epp.tld.ee/schema/epp-ee-1.0.xsd">
          <command>
            <update>
              <contact:update xmlns:contact="https://epp.tld.ee/schema/contact-ee-1.1.xsd">
                <contact:id>TEST</contact:id>
                <contact:chg>
                  <contact:postalInfo>
                    <contact:name>test</contact:name>
                  </contact:postalInfo>
                </contact:chg>
              </contact:update>
            </update>
            <extension>
              <eis:extdata xmlns:eis="https://epp.tld.ee/schema/eis-1.0.xsd">
                <eis:ident cc="US" type="priv">another-test</eis:ident>
              </eis:extdata>
            </extension>
          </command>
        </epp>
      XML
      }

      it 'does not update code' do
        expect do
          request
          contact.reload
        end.to_not change { ident.code }
      end

      it 'does not update type' do
        expect do
          request
          contact.reload
        end.to_not change { ident.type }
      end

      it 'does not update country code' do
        expect do
          request
          contact.reload
        end.to_not change { ident.country_code }
      end

      specify do
        request
        expect(Epp::Response.xml(response.body).code?(Epp::Response::Result::Code.key(:data_management_policy_violation))).to be_truthy
      end
    end
  end
end
