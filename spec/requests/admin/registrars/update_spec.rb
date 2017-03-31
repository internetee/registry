require 'rails_helper'

RSpec.describe 'admin registrar update' do
  before :example do
    sign_in_to_admin_area
  end

  it 'updates website' do
    registrar = create(:registrar, website: 'test')

    patch admin_registrar_path(registrar), registrar: attributes_for(:registrar, website: 'new-website')
    registrar.reload

    expect(registrar.website).to eq('new-website')
  end

  it 'redirects to :show' do
    registrar = create(:registrar)

    patch admin_registrar_path(registrar), { registrar: attributes_for(:registrar) }

    expect(response).to redirect_to admin_registrar_path(registrar)
  end

  context 'when trigger-attribute is changed' do
    let!(:registrar) { create(:registrar, name: 'old-name') }
    let!(:domain) { create(:domain, registrar: registrar, name: 'test.com') }

    it 'updates whois of related domain names' do
      expect(DNS::DomainName).to receive(:update_whois).with(domain_name: 'test.com')
      patch admin_registrar_path(registrar), { registrar: registrar.attributes.merge({ name: 'new-name' }) }
    end
  end

  context 'when trigger-attribute is not changed' do
    let!(:registrar) { create(:registrar, reg_no: 'old-reg-no') }
    let!(:domain) { create(:domain, registrar: registrar, name: 'test.com') }

    it 'does not update whois of related domain names' do
      expect(DNS::DomainName).to_not receive(:update_whois)
      patch admin_registrar_path(registrar), { registrar: registrar.attributes.merge({ reg_no: 'new-reg-no' }) }
    end
  end
end
