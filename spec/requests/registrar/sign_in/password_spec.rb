require 'rails_helper'

RSpec.describe 'Registrar area password sign-in', settings: false do
  let!(:user) { create(:api_user, active: true, login: 'test', password: 'testtest') }

  before do
    Setting.registrar_ip_whitelist_enabled = false
  end

  it 'signs the user in' do
    post registrar_sessions_path, depp_user: { tag: 'test', password: 'testtest' }
    follow_redirect!
    expect(controller.current_user).to eq(user)
  end

  it 'redirects to root url' do
    post registrar_sessions_path, depp_user: { tag: 'test', password: 'testtest' }
    expect(response).to redirect_to(registrar_root_url)
  end
end
