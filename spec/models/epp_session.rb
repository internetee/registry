require 'rails_helper'

describe EppSession do
  let(:epp_session) { create(:epp_session) }

  it 'has marshalled data' do
    expect(epp_session.read_attribute(:data)).to_not be_blank
    expect(epp_session.read_attribute(:data).class).to eq(String)
    expect(epp_session.data.class).to eq(Hash)
  end

  it 'stores data' do
    expect(epp_session[:api_user_id]).to eq(1)

    epp_session[:api_user_id] = 3
    expect(epp_session[:api_user_id]).to eq(3)

    epp_session =  EppSession.find_by(session_id: 'test')
    expect(epp_session[:api_user_id]).to eq(3)
  end
end
