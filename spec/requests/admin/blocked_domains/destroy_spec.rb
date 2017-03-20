require 'rails_helper'

RSpec.describe 'admin blocked domain destroy' do
  let!(:blocked_domain) { create(:blocked_domain) }

  before :example do
    sign_in_to_admin_area
  end

  it 'deletes blocked domain' do
    expect { delete admin_blocked_domain_path(blocked_domain) }.to change { BlockedDomain.count }.from(1).to(0)
  end

  it 'redirects to :index' do
    delete admin_blocked_domain_path(blocked_domain)

    expect(response).to redirect_to admin_blocked_domains_url
  end
end
