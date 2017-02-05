require 'rails_helper'

RSpec.describe Admin::DisputesController do
  before :example do
    sign_in_to_admin_area
  end

  describe '#new' do
    let!(:domain) { create(:domain) }
    let(:request) { post admin_disputes_path,
                         { dispute: attributes_for(:dispute, domain_name: domain.name) } }

    it 'creates new dispute' do
      expect { request }.to change { Dispute.count }.from(0).to(1)
    end

    it 'redirects to dispute list' do
      request
      expect(response).to redirect_to admin_disputes_path
    end
  end

  describe '#update' do
    it 'updates expire date' do
      dispute = create(:dispute, expire_date: Time.zone.parse('05.07.2010').to_date)
      patch admin_dispute_path(dispute),
            dispute: attributes_for(:dispute, expire_date: Time.zone.parse('06.07.2010').to_date.to_s)
      dispute.reload
      expect(dispute.expire_date).to eq(Time.zone.parse('06.07.2010').to_date)
    end

    it 'redirects to dispute list' do
      dispute = create(:dispute)
      patch admin_dispute_path(dispute), dispute: { password: 'test' }
      request
      expect(response).to redirect_to admin_disputes_path
    end
  end

  describe '#destroy' do
    let!(:dispute) { create(:dispute) }
    let(:request) { delete admin_dispute_path(dispute) }

    it 'deletes dispute' do
      expect { request }.to change { Dispute.count }.from(1).to(0)
    end

    it 'redirects to dispute list' do
      request
      expect(response).to redirect_to admin_disputes_path
    end
  end
end
