require 'rails_helper'

describe Keyrelay do
  it { should belong_to(:domain) }
  it { should belong_to(:requester) }
  it { should belong_to(:accepter) }
  it { should have_many(:legal_documents) }

  it 'is in pending status' do
    kr = Fabricate(:keyrelay)
    expect(kr.status).to eq('pending')
  end

  it 'is in expired status' do
    kr = Fabricate(:keyrelay, pa_date: DateTime.now - 2.weeks)
    expect(kr.status).to eq('expired')
  end

  it 'does not accept invalid relative expiry' do
    kr = Fabricate.build(:keyrelay, expiry_relative: 'adf')
    expect(kr.save).to eq(false)
    expect(kr.errors[:expiry_relative].first).to eq('Expiry relative must be compatible to ISO 8601')
  end
end
