require 'test_helper'
require 'application_system_test_case'

class AdminAreaBlockedDomainsIntegrationTest < JavaScriptApplicationSystemTestCase
  setup do
    WebMock.allow_net_connect!
    sign_in users(:admin)

    @domain = domains(:shop)
    @blocked_domain = blocked_domains(:one)
  end

  def test_page_successfully_loaded
    visit_admin_blocked_domains
  end

  def test_add_into_blocked_list
    visit_admin_blocked_domains
    add_blocked_domain(success: true)
  end

  def test_add_into_blocked_list_same_domain
    visit_admin_blocked_domains
    add_blocked_domain(success: true)
    add_blocked_domain(success: false)
  end

  def test_delete_domain_from_blocked_list
    setup_blocked_domain

    delete_first_blocked_domain
    assert_text 'Domain deleted!'
  end

  def test_find_blocked_domain_from_blocked_list
    setup_blocked_domain

    search_blocked_domain(@domain.name)
    assert_text @domain.name
  end

  def test_download_blocked_domains
    now = Time.zone.parse('2010-07-05 08:00')
    travel_to now

    get admin_blocked_domains_path(format: :csv)

    assert_response :ok
    assert_equal 'text/csv; charset=utf-8', response.headers['Content-Type']
    assert_not_empty response.body
  end

  private

  def visit_admin_blocked_domains
    visit admin_blocked_domains_path
    assert_text 'Blocked domains'
  end

  def add_blocked_domain(success:)
    click_on 'New blocked domain'
    assert_text 'Add domain to blocked list'

    fill_in 'Name', with: @domain.name
    safe_click_on 'Save'

    if success
      assert_text 'Domain added!'
      assert_no_css '.modal.show'
    else
      assert_text 'Failed to add domain!'
    end
  end

  def setup_blocked_domain
    visit_admin_blocked_domains
    add_blocked_domain(success: true)
  end

  def delete_first_blocked_domain
    accept_confirm { click_link_or_button 'Delete', match: :first }
  rescue Selenium::WebDriver::Error::UnknownError => e
    raise unless e.message.include?('Node with given id does not belong to the document')
    accept_confirm { click_link_or_button 'Delete', match: :first }
  end

  def search_blocked_domain(name)
    fill_in 'Name', with: name
    find('.glyphicon-search').click
  end

  def safe_click_on(locator, **options)
    click_on locator, **options
  rescue Selenium::WebDriver::Error::UnknownError => e
    raise unless e.message.include?('Node with given id does not belong to the document')
    click_on locator, **options
  end
end
