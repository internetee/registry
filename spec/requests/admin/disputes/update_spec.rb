require 'rails_helper'

RSpec.describe 'admin dispute update' do
  before :example do
    travel_to Time.zone.parse('05.07.2010')
    sign_in_to_admin_area
  end

  it 'updates password' do
    dispute = create(:dispute, password: 'test')

    patch admin_dispute_path(dispute), dispute: attributes_for(:dispute, password: 'new password')
    dispute.reload

    expect(dispute.password).to eq('new password')
  end

  it 'generates password' do
    dispute = create(:dispute, password: 'test')

    patch admin_dispute_path(dispute), dispute: attributes_for(:dispute, password: '')
    dispute.reload

    expect(dispute.password).to_not eq('test')
  end

  it 'updates expiration date' do
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

  it 'redirects to :show' do
    dispute = create(:dispute)

    patch admin_dispute_path(dispute), dispute: { password: 'test' }
    request

    expect(response).to redirect_to admin_dispute_path(dispute)
  end
end
