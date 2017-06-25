require 'rails_helper'

RSpec.describe 'admin blocked domain destroy' do
  before :example do
    sign_in_to_admin_area
  end

  it 'deletes blocked domain' do
    blocked_domain = create(:blocked_domain)

    expect { delete admin_blocked_domain_path(blocked_domain) }.to change { BlockedDomain.count }.from(1).to(0)
  end

  it 'updates whois' do
    blocked_domain = create(:blocked_domain, name: 'test.com')

    expect(DNS::DomainName).to receive(:update_whois).with(domain_name: 'test.com')

    delete admin_blocked_domain_path(blocked_domain)
  end

  it 'redirects to :index' do
    blocked_domain = create(:blocked_domain)

    delete admin_blocked_domain_path(blocked_domain)

    expect(response).to redirect_to admin_blocked_domains_url
  end
end
