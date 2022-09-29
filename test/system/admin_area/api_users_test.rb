require 'application_system_test_case'

class AdminApiUsersSystemTest < ApplicationSystemTestCase
  setup do
    sign_in users(:admin)
    @registrar = registrars(:bestnames)
  end

  def test_shows_api_user_list
    visit admin_api_users_path

    api_user = users(:api_bestnames)
    assert_link api_user.username, href: admin_registrar_api_user_path(api_user.registrar, api_user)
  end

  def test_should_display_tests_button_in_api_user
    visit admin_api_users_path

    assert_button 'Set Test'
    assert_no_button 'Remove Test'
  end

  def test_should_display_remove_test_if_there_accreditated_apiuser
    date = Time.zone.now - 10.minutes

    api_user = @registrar.api_users.first
    api_user.accreditation_date = date
    api_user.accreditation_expire_date = api_user.accreditation_date + 1.year
    api_user.save

    visit admin_api_users_path

    assert_button 'Remove Test'
  end

  def test_should_not_display_remove_test_if_api_user_accreditation_date_is_expired
    date = Time.zone.now - 1.year - 10.minutes

    api_user = @registrar.api_users.first
    api_user.accreditation_date = date
    api_user.accreditation_expire_date = api_user.accreditation_date + 1.year
    api_user.save

    visit admin_api_users_path

    assert_no_button 'Remove'
  end

  def test_should_display_tests_button_in_api_user_details
    api_user = @registrar.api_users.first

    visit admin_api_user_path(api_user)
    assert_button 'Set Test'
    assert_no_button 'Remove Test'
  end

  def test_should_display_remove_test_in_api_user_details_if_there_accreditated_apiuser
    date = Time.zone.now - 10.minutes

    api_user = @registrar.api_users.first
    api_user.accreditation_date = date
    api_user.accreditation_expire_date = api_user.accreditation_date + 1.year
    api_user.save

    visit admin_api_user_path(api_user)

    assert_button 'Remove Test'
  end

  def test_should_not_display_remove_test_if_api_user_accreditation_date_is_expired_in_api_details
    date = Time.zone.now - 1.year - 10.minutes

    api_user = @registrar.api_users.first
    api_user.accreditation_date = date
    api_user.accreditation_expire_date = api_user.accreditation_date + 1.year
    api_user.save

    visit admin_api_user_path(api_user)

    assert_no_button 'Remove'
  end
end
