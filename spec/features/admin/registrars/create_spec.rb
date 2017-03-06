require 'rails_helper'

RSpec.feature 'New registrar' do
  background do
    sign_in_to_admin_area
  end

  it 'creates registrar' do
    visit admin_registrars_url
    click_link_or_button 'New registrar'

    fill_in 'registrar[name]', with: 'test'
    fill_in 'registrar[reg_no]', with: '1234567'
    fill_in 'registrar[email]', with: 'test@test.com'
    fill_in 'registrar[code]', with: 'test'
    click_link_or_button 'Create registrar'

    expect(page).to have_text('Registrar has been successfully created')
  end
end
