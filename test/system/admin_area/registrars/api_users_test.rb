require 'application_system_test_case'

class AdminRegistrarsApiUsersSystemTest < ApplicationSystemTestCase
  setup do
    sign_in users(:admin)
  end

  def test_creates_new_api_user_with_required_attributes
    username = 'john'
    registrar = registrars(:bestnames)

    visit admin_registrar_path(registrar)
    click_on 'New API user'

    fill_in 'Username', with: username
    fill_in 'Password', with: valid_password
    click_on 'Create API user'

    assert_text 'API user has been successfully created'
    assert_text "Username #{username}"
    new_api_user = ApiUser.last
    assert_current_path admin_registrar_api_user_path(registrar, new_api_user)
  end

  def test_downloads_api_users_list_as_csv
    travel_to Time.zone.parse('2010-07-05 10:30')
    registrar = registrars(:bestnames)
    api_users = registrar.api_users
    api_users.each do |u|
      u.created_at = Time.zone.now
      u.updated_at = Time.zone.now
      u.save(validate: false)
    end

    visit admin_registrar_path(registrar)
    within('.api_users') do
      click_on 'Export to CSV'
    end

    assert_equal "attachment; filename=\"#{registrar.name.parameterize}_api_users_#{Time.zone.now.to_formatted_s(:number)}.csv\"; " \
      "filename*=UTF-8''#{registrar.name.parameterize}_api_users_#{Time.zone.now.to_formatted_s(:number)}.csv", response_headers['Content-Disposition']
    assert_equal file_fixture('api_users.csv').read, page.body
  end

  def test_shows_api_user_details
    api_user = users(:api_bestnames)

    visit admin_registrar_path(api_user.registrar)
    click_on api_user.username

    assert_text "Username #{api_user.username}"
    assert_text "Password #{api_user.plain_text_password}"
    assert_link api_user.registrar.name, href: admin_registrar_path(api_user.registrar)
    assert_text "Role #{api_user.roles.first}"
    assert_text "Active #{api_user.active}"
  end

  def test_updates_api_user
    api_user = users(:api_bestnames)
    new_username = 'new username'
    assert_not_equal new_username, api_user.username

    visit admin_registrar_api_user_path(api_user.registrar, api_user)
    click_link_or_button 'Edit'
    fill_in 'Username', with: new_username
    click_link_or_button 'Update API user'

    assert_text 'API user has been successfully updated'
    assert_text "Username #{new_username}"
    assert_current_path admin_registrar_api_user_path(api_user.registrar, api_user)
  end

  def test_deletes_api_user
    api_user = unassociated_api_user

    visit admin_registrar_api_user_path(api_user.registrar, api_user)
    click_on 'Delete'

    assert_text 'API user has been successfully deleted'
    assert_current_path admin_registrar_path(api_user.registrar)
  end

  private

  def unassociated_api_user
    new_api_user = users(:api_bestnames).dup
    new_api_user.username = "unique-#{rand(100)}"
    new_api_user.save!
    new_api_user
  end

  def valid_password
    'testtest'
  end
end
