require 'rails_helper'

RSpec.describe 'Admin area zone file generation', settings: false do
  let!(:zone) { create(:zone, origin: 'com') }

  before do
    sign_in_to_admin_area
  end

  it 'generates new' do
    post admin_zonefiles_path(origin: 'com')
    expect(response).to be_success
  end
end
