require 'test_helper'
require 'application_system_test_case'

class AdminAreaReservedDomainsIntegrationTest < JavaScriptApplicationSystemTestCase

  setup do
    WebMock.allow_net_connect!
    @original_default_language = Setting.default_language
    sign_in users(:admin)

    @reserved_domain = reserved_domains(:one)
  end

  def test_remove_reserved_domain
    visit admin_reserved_domains_path  
    click_link_or_button 'Delete', match: :first
    page.driver.browser.switch_to.alert.accept

    assert_text 'Domain deleted!'
  end

  def test_add_invalid_domain
    visit admin_reserved_domains_path
    click_on 'New reserved domain'
    fill_in "Name", with: "@##@$"
    click_on 'Save'

    assert_text 'Failed to add domain!'
  end

  def test_update_reserved_domain
    visit admin_reserved_domains_path
    click_link_or_button 'Edit Pw', match: :first
    fill_in 'Password', with: '12345678'
    click_on 'Save'

    assert_text 'Domain updated!'
  end
end
