require 'application_system_test_case'

class AdminAreaNewApiUserTest < ApplicationSystemTestCase
  setup do
    sign_in users(:admin)
  end

  def test_new_api_user_creation_with_required_params
    visit admin_api_users_url
    click_link_or_button 'New API user'

    fill_in 'Username', with: 'newtest'
    fill_in 'Password', with: 'testtest'
    find('#api_user_registrar_id', visible: false).set(registrars(:bestnames).id)

    assert_difference 'ApiUser.count' do
      click_link_or_button 'Save'
    end

    assert_current_path admin_api_user_path(ApiUser.last)
    assert_text 'Record created'
    assert_text 'Username newtest'
    assert_text 'Password testtest'
  end
end