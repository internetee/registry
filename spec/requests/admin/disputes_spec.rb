require 'rails_helper'

RSpec.describe Admin::DisputesController do
  before :example do
    travel_to Time.zone.parse('05.07.2010')
    sign_in_to_admin_area
  end

  describe '#new' do
    let!(:domain) { create(:domain) }
    let(:request) { post admin_disputes_path,
                         { dispute: attributes_for(:dispute,
                                                   domain_name: domain.name) }
    }
    subject(:dispute) { Dispute.first }

    it 'creates new dispute' do
      expect { request }.to change { Dispute.count }.from(0).to(1)
    end

    it 'saves date of expiry' do
      post admin_disputes_path, { dispute: attributes_for(:dispute,
                                                          domain_name: domain.name,
                                                          expire_date: localize(Date.parse('05.07.2010')))
      }
      expect(dispute.expire_date).to eq(Date.parse('05.07.2010'))
    end

    it 'saves password' do
      post admin_disputes_path, { dispute: attributes_for(:dispute,
                                                          domain_name: domain.name,
                                                          password: 'test')
      }
      expect(dispute.password).to eq('test')
    end

    it 'saves comment' do
      post admin_disputes_path, { dispute: attributes_for(:dispute,
                                                          domain_name: domain.name,
                                                          comment: 'test')
      }
      expect(dispute.comment).to eq('test')
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
