require 'rails_helper'

RSpec.describe 'admin reserved domain destroy' do
  let!(:reserved_domain) { create(:reserved_domain) }

  before :example do
    sign_in_to_admin_area
  end

  it 'deletes reserved domain' do
    expect { delete admin_reserved_domain_path(reserved_domain) }.to change { ReservedDomain.count }.from(1).to(0)
  end

  it 'updates whois' do
    reserved_domain = create(:reserved_domain, name: 'test.com')

    expect(DNS::DomainName).to receive(:update_whois).with(domain_name: 'test.com')

    delete admin_reserved_domain_path(reserved_domain)
  end

  it 'redirects to :index' do
    delete admin_reserved_domain_path(reserved_domain)

    expect(response).to redirect_to admin_reserved_domains_url
  end
end
