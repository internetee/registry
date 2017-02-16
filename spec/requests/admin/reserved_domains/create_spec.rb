require 'rails_helper'

RSpec.describe 'admin reserved domain create' do
  subject(:reserved_domain) { ReservedDomain.first }

  before :example do
    sign_in_to_admin_area
  end

  it 'creates new reserved domain' do
    expect { post admin_reserved_domains_path, reserved_domain: attributes_for(:reserved_domain) }
      .to change { ReservedDomain.count }.from(0).to(1)
  end

  it 'saves domain name' do
    post admin_reserved_domains_path, reserved_domain: attributes_for(:reserved_domain,
                                                                      name: 'test.com')
    expect(reserved_domain.name).to eq('test.com')
  end

  it 'saves password' do
    post admin_reserved_domains_path, reserved_domain: attributes_for(:reserved_domain,
                                                                      password: 'test')
    expect(reserved_domain.password).to eq('test')
  end

  it 'generates password' do
    post admin_reserved_domains_path, reserved_domain: attributes_for(:reserved_domain,
                                                                      password: '')
    expect(reserved_domain.password).to be_present
  end

  it 'redirects to :index' do
    post admin_reserved_domains_path, reserved_domain: attributes_for(:reserved_domain)
    expect(response).to redirect_to admin_reserved_domains_path
  end

  context 'when domain name is disputed' do
    let!(:dispute) { create(:dispute,
                            domain_name: 'test.com',
                            password: 'dispute-password') }

    it 'replaces password with the one from dispute' do
      post admin_reserved_domains_path, reserved_domain: attributes_for(:reserved_domain,
                                                                        name: 'test.com',
                                                                        password: 'reserved-domain-password')
      expect(reserved_domain.password).to eq('dispute-password')
    end
  end
end
