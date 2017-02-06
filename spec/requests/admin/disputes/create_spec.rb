require 'rails_helper'

RSpec.describe 'admin dispute create' do
  before :example do
    travel_to Time.zone.parse('05.07.2010')
    sign_in_to_admin_area
  end

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

  it 'generates password' do
    post admin_disputes_path, { dispute: attributes_for(:dispute,
                                                        domain_name: domain.name,
                                                        password: '')
    }
    expect(dispute.password).to be_present
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
