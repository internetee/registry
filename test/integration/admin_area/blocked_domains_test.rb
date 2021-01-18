require 'test_helper'
require 'application_system_test_case'


# /admin/blocked_domains
class AdminAreaBlockedDomainsIntegrationTest < JavaScriptApplicationSystemTestCase  
  setup do
    WebMock.allow_net_connect!
    sign_in users(:admin)
    @domain = domains(:shop)
    @blocked_domain = blocked_domains(:one)
  end

  # HELPERS
  def visit_admin_blocked_domains_path
    visit admin_blocked_domains_path
    assert_text 'Blocked domains'
  end

  def add_domain_into_blocked_list(value)
    click_on 'New blocked domain'
    assert_text 'Add domain to blocked list'

    fill_in 'Name', with: @domain.name
    click_on 'Save'

    return assert_text 'Domain added!' if value
    return assert_text 'Failed to add domain!'
  end

  # ------------------------------------------------------------
  # TESTs
  def test_page_successfully_loaded
    visit_admin_blocked_domains_path
  end

  def test_add_into_blocked_list
    visit_admin_blocked_domains_path
    add_domain_into_blocked_list(true)
  end

  def test_add_into_blocked_list_same_domain
    visit_admin_blocked_domains_path
    add_domain_into_blocked_list(true)
    add_domain_into_blocked_list(false)
  end

  def test_delete_domain_from_blocked_list
    visit_admin_blocked_domains_path
    add_domain_into_blocked_list(true)

    click_link_or_button 'Delete', match: :first

     # Accept to delete in modal window
     page.driver.browser.switch_to.alert.accept

     assert_text 'Domain deleted!'
  end

  def test_find_blocked_domain_from_blocked_list
    visit_admin_blocked_domains_path
    add_domain_into_blocked_list(true)

    fill_in 'Name', with: @domain.name
    find(:xpath, "//span[@class='glyphicon glyphicon-search']").click

    assert_text @domain.name
  end

  def test_set_domain
    assert_equal @blocked_domain.name, BlockedDomain.find(name: @blocked_domain.name)
  end

end