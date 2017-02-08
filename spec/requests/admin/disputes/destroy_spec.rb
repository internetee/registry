require 'rails_helper'

RSpec.describe 'admin dispute destroy' do
  let!(:dispute) { create(:dispute) }
  let(:request) { delete admin_dispute_path(dispute) }

  before :example do
    sign_in_to_admin_area
  end

  it 'deletes dispute' do
    expect { request }.to change { Dispute.count }.from(1).to(0)
  end

  it 'redirects to :index' do
    request
    expect(response).to redirect_to admin_disputes_path
  end
end
