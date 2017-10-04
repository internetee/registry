require 'rails_helper'

RSpec.feature 'Registrar area user switch', settings: false do
  given!(:current_user) { create(:api_user, id: 1, identity_code: 'test') }
  given!(:new_user) { create(:api_user, id: 2, identity_code: 'test', username: 'new-user-name') }

  background do
    sign_in_to_registrar_area(user: current_user)
  end

  scenario 'successful user switch' do
    visit registrar_root_path
    click_link_or_button 'switch-current-user-2-btn'
    expect(page).to have_text('You are now signed in as a user "new-user-name"')
  end
end
