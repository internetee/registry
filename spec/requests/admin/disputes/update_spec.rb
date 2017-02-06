require 'rails_helper'

RSpec.describe 'admin dispute update' do
  before :example do
    travel_to Time.zone.parse('05.07.2010')
    sign_in_to_admin_area
  end

  it 'updates expire date' do
    dispute = create(:dispute, expire_date: Time.zone.parse('05.07.2010').to_date)
    patch admin_dispute_path(dispute),
          dispute: attributes_for(:dispute, expire_date: Time.zone.parse('06.07.2010').to_date.to_s)
    dispute.reload
    expect(dispute.expire_date).to eq(Time.zone.parse('06.07.2010').to_date)
  end

  it 'updates comment' do
    dispute = create(:dispute, comment: 'test')
    patch admin_dispute_path(dispute),
          dispute: attributes_for(:dispute, comment: 'new comment')
    dispute.reload
    expect(dispute.comment).to eq('new comment')
  end

  it 'redirects to dispute list' do
    dispute = create(:dispute)
    patch admin_dispute_path(dispute), dispute: { password: 'test' }
    request
    expect(response).to redirect_to admin_disputes_path
  end
end
