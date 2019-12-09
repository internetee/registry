require 'application_system_test_case'

class AdminApiUsersSystemTest < ApplicationSystemTestCase
  setup do
    sign_in users(:admin)
  end

  def test_shows_api_user_list
    visit admin_api_users_path

    api_user = users(:api_bestnames)
    assert_link api_user.username, href: admin_api_user_path(api_user)
  end

  def test_shows_api_user_details
    api_user = users(:api_bestnames)

    visit admin_api_user_path(api_user)

    assert_text "Username #{api_user.username}"
    assert_text "Password #{api_user.plain_text_password}"
    assert_link api_user.registrar.name, href: admin_registrar_path(api_user.registrar)
    assert_text "Role #{api_user.roles.first}"
    assert_text "Active #{api_user.active}"
  end

  def test_updates_api_user
    api_user = users(:api_bestnames)
    new_username = 'new username'
    assert_not_equal new_username, api_user.name

    visit admin_api_user_path(api_user)
    click_link_or_button 'Edit'
    fill_in 'Username', with: new_username
    click_link_or_button 'Save'

    assert_text 'Record updated'
    assert_text "Username #{new_username}"
  end

  def test_deletes_api_user
    api_user = unassociated_api_user

    visit admin_api_user_path(api_user)
    click_on 'Delete'

    assert_text 'Record deleted'
  end

  private

  def unassociated_api_user
    new_api_user = users(:api_bestnames).dup
    new_api_user.username = "unique-#{rand(100)}"
    new_api_user.save!
    new_api_user
  end
end
