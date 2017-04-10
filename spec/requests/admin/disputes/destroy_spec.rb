require 'rails_helper'

RSpec.describe 'admin dispute destroy' do
  let!(:dispute) { create(:dispute) }

  before :example do
    sign_in_to_admin_area
  end

  it 'deletes dispute' do
    expect { delete admin_dispute_path(dispute) }.to change { Dispute.count }.from(1).to(0)
  end

  it 'updates whois' do
    dispute = create(:dispute, domain_name: 'test.com')

    expect(DNS::DomainName).to receive(:update_whois).with(domain_name: 'test.com')

    delete admin_dispute_path(dispute)
  end

  it 'redirects to :index' do
    delete admin_dispute_path(dispute)

    expect(response).to redirect_to admin_disputes_url
  end
end
