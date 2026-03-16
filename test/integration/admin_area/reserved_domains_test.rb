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
    click_link_or_button 'Edit', match: :first
    fill_in 'Password', with: '12345678'
    click_on 'Save'

    assert_text 'Domain updated!'
  end

  def test_download_reserved_domains
    now = Time.zone.parse('2010-07-05 08:00')
    travel_to now

    get admin_reserved_domains_path(format: :csv)

    assert_response :ok
    assert_equal 'text/csv; charset=utf-8', response.headers['Content-Type']
    assert_equal %(attachment; filename="reserved_domains_#{Time.zone.now.to_formatted_s(:number)}.csv"; filename*=UTF-8''reserved_domains_#{Time.zone.now.to_formatted_s(:number)}.csv),
                 response.headers['Content-Disposition']
    assert_not_empty response.body
  end

  def test_release_to_auction
    visit admin_reserved_domains_path
  
    first("input[type='checkbox']").set(true)
  
    click_on 'Send to the auction list'
  
    assert_current_path admin_auctions_path
  
    assert_text 'reserved.test'
    assert_text 'started'
  end
end
