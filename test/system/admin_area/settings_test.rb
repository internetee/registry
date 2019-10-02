require 'application_system_test_case'

class AdminAreaSettingsTest < ApplicationSystemTestCase
  setup do
    sign_in users(:admin)
  end

  def test_saves_settings
    visit admin_settings_url
    click_link_or_button 'Save'
    assert_text 'Settings have been successfully updated'
  end
end
