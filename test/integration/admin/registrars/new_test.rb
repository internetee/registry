require 'test_helper'

class AdminAreaNewRegistrarTest < ActionDispatch::IntegrationTest
  setup do
    login_as users(:admin)
  end

  def test_new_registrar_creation_with_required_params
    visit admin_registrars_url
    click_link_or_button 'New registrar'

    fill_in 'Name', with: 'Brand new names'
    fill_in 'Reg no', with: '55555555'
    fill_in 'Contact e-mail', with: 'test@example.com'
    fill_in 'Accounting customer code', with: 'test'
    fill_in 'Code', with: 'test'

    assert_difference 'Registrar.count' do
      click_link_or_button 'Create registrar'
    end

    assert_current_path admin_registrar_path(Registrar.last)
    assert_text 'Registrar has been successfully created'
  end

  def test_fails_gracefully
    visit admin_registrars_url
    click_link_or_button 'New registrar'

    fill_in 'Name', with: 'Best Names'
    fill_in 'Reg no', with: '55555555'
    fill_in 'Contact e-mail', with: 'test@example.com'
    fill_in 'Accounting customer code', with: 'test'
    fill_in 'Code', with: 'test'

    assert_no_difference 'Registrar.count' do
      click_link_or_button 'Create registrar'
    end
    assert_field 'Name', with: 'Best Names'
    assert_text 'Name has already been taken'
  end

  def test_pre_populated_default_language
    Setting.default_language = 'en'
    visit admin_registrars_url
    click_link_or_button 'New registrar'
    assert_field 'Language', with: 'en'
  end
end
