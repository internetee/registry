require 'rails_helper'

RSpec.describe 'admin reserved domain update' do
  before :example do
    sign_in_to_admin_area
  end

  it 'does not update domain name' do
    reserved_domain = create(:reserved_domain, name: 'test.com')

    patch admin_reserved_domain_path(reserved_domain), reserved_domain: attributes_for(:reserved_domain,
                                                                                       name: 'new.com')
    reserved_domain.reload

    expect(reserved_domain.name).to eq('test.com')
  end

  it 'updates password' do
    reserved_domain = create(:reserved_domain, password: 'test')

    patch admin_reserved_domain_path(reserved_domain), reserved_domain: attributes_for(:reserved_domain,
                                                                                       password: 'new-password')
    reserved_domain.reload

    expect(reserved_domain.password).to eq('new-password')
  end

  it 'generates password' do
    reserved_domain = create(:reserved_domain, password: 'test')

    patch admin_reserved_domain_path(reserved_domain), reserved_domain: attributes_for(:reserved_domain,
                                                                                       password: '')
    reserved_domain.reload

    expect(reserved_domain.password).to_not eq('test')
  end

  it 'redirects to :index' do
    reserved_domain = create(:reserved_domain)

    patch admin_reserved_domain_path(reserved_domain), reserved_domain: attributes_for(:reserved_domain)

    expect(response).to redirect_to admin_reserved_domains_path
  end

  context 'when domain name is disputed' do
    let!(:reserved_domain) { create(:reserved_domain, name: 'test.com') }
    let!(:dispute) { create(:dispute,
                            domain_name: 'test.com',
                            password: 'dispute-password') }

    it 'throws exception' do
      expect {
        patch admin_reserved_domain_path(reserved_domain),
              reserved_domain:
                attributes_for(:reserved_domain, password: 'reserved-domain-password') }
        .to raise_error('Editing is prohibited while domain name is disputed')
    end
  end
end
