require 'rails_helper'

RSpec.feature 'Registrar area password sign-in' do
  scenario 'signs in the user with valid credentials' do
    create(:api_user_with_unlimited_balance,
           active: true,
           login: 'test',
           password: 'testtest')

    visit registrar_login_path
    sign_in_with 'test', 'testtest'

    expect(page).to have_text(t('registrar.base.current_user.sign_out'))
  end

  scenario 'notifies the user with invalid credentials' do
    create(:api_user, login: 'test', password: 'testtest')

    visit registrar_login_path
    sign_in_with 'test', 'invalid'

    expect(page).to have_text('No such user')
  end

  scenario 'notifies the user with inactive account' do
    create(:api_user, active: false, login: 'test', password: 'testtest')

    visit registrar_login_path
    sign_in_with 'test', 'testtest'

    expect(page).to have_text('User is not active')
  end

  def sign_in_with(username, password)
    fill_in 'depp_user_tag', with: username
    fill_in 'depp_user_password', with: password
    click_button 'Login'
  end
end
