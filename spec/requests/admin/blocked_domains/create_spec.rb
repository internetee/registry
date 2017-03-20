require 'rails_helper'

RSpec.describe 'admin blocked domain create' do
  subject(:blocked_domain) { BlockedDomain.first }

  before :example do
    sign_in_to_admin_area
  end

  it 'creates new blocked domain' do
    expect { post admin_blocked_domains_path, blocked_domain: attributes_for(:blocked_domain) }
      .to change { BlockedDomain.count }.from(0).to(1)
  end

  it 'saves domain name' do
    post admin_blocked_domains_path, blocked_domain: attributes_for(:blocked_domain,
                                                                    name: 'test.com')
    expect(blocked_domain.name).to eq('test.com')
  end

  it 'redirects to :index' do
    post admin_blocked_domains_path, blocked_domain: attributes_for(:blocked_domain)

    expect(response).to redirect_to admin_blocked_domains_url
  end
end
