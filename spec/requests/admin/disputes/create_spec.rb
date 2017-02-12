require 'rails_helper'

RSpec.describe 'admin dispute create' do
  before :example do
    travel_to Time.zone.parse('05.07.2010')
    sign_in_to_admin_area
  end

  subject(:dispute) { Dispute.first }

  it 'creates new dispute' do
    expect { post admin_disputes_path, { dispute: attributes_for(:dispute) } }
      .to change { Dispute.count }.from(0).to(1)
  end

  it 'saves domain name' do
    post admin_disputes_path, { dispute: attributes_for(:dispute,
                                                        domain_name: 'test.com')
    }
    expect(dispute.domain_name).to eq('test.com')
  end

  it 'saves password' do
    post admin_disputes_path, { dispute: attributes_for(:dispute,
                                                        password: 'test')
    }
    expect(dispute.password).to eq('test')
  end

  it 'generates password' do
    post admin_disputes_path, { dispute: attributes_for(:dispute,
                                                        password: '')
    }
    expect(dispute.password).to be_present
  end

  it 'saves expiration date' do
    post admin_disputes_path, { dispute: attributes_for(:dispute,
                                                        expire_date: localize(Date.parse('05.07.2010')))
    }
    expect(dispute.expire_date).to eq(Date.parse('05.07.2010'))
  end

  it 'saves comment' do
    post admin_disputes_path, { dispute: attributes_for(:dispute,
                                                        comment: 'test')
    }
    expect(dispute.comment).to eq('test')
  end

  it 'redirects to :show' do
    post admin_disputes_path, { dispute: attributes_for(:dispute) }
    expect(response).to redirect_to admin_dispute_path(dispute)
  end

  context 'when domain is present' do
    let!(:domain) { create(:domain, name: 'test.com') }

    it 'prohibits registrant change' do
      expect {
        post admin_disputes_path, { dispute: attributes_for(:dispute, domain_name: 'test.com') }
        domain.reload
      }.to change { domain.registrant_change_prohibited? }.from(false).to(true)
    end
  end
end
