require 'rails_helper'

RSpec.feature 'Edit registrar' do
  given!(:registrar) { create(:registrar_with_unlimited_balance) }

  background do
    sign_in_to_admin_area
  end

  it 'updates registrar' do
    visit admin_registrar_url(registrar)
    click_link_or_button 'Edit'

    click_link_or_button 'Update registrar'

    expect(page).to have_text('Registrar has been successfully updated')
  end
end
