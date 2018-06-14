require 'rails_helper'

RSpec.feature 'Registrar area linked users', settings: false do
  given!(:current_user) { create(:api_user_with_unlimited_balance, id: 1, identity_code: 'test') }
  given!(:linked_user) { create(:api_user_with_unlimited_balance, id: 2, identity_code: 'test',
                                username: 'new-user-name') }

  background do
    sign_in_to_registrar_area(user: current_user)
  end

  scenario 'switches current user to a linked one' do
    visit registrar_profile_path
    click_link_or_button 'switch-current-user-2-btn'
    expect(page).to have_text('You are now signed in as a user "new-user-name"')
  end
end
