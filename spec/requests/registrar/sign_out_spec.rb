require 'rails_helper'

RSpec.describe 'Registrar area sign-out', settings: false do
  before do
    Setting.registrar_ip_whitelist_enabled = false
    sign_in_to_registrar_area
  end

  it 'signs the user out' do
    delete registrar_destroy_user_session_path
    follow_redirect!
    expect(controller.current_user).to be_nil
  end

  it 'redirects to login url' do
    delete registrar_destroy_user_session_path
    expect(response).to redirect_to(registrar_login_url)
  end
end
