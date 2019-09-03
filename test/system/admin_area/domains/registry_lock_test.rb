require 'test_helper'

class AdminAreaRegistryLockTest < JavaScriptApplicationSystemTestCase
  def setup
    super
    WebMock.allow_net_connect!

    sign_in users(:admin)
    travel_to Time.zone.parse('2010-07-05 00:30:00')
    @domain = domains(:airport)
  end

  def test_does_not_have_link_when_domain_is_not_locked
    visit edit_admin_domain_path(@domain)
    click_link_or_button('Actions')
    refute(page.has_link?('Remove registry lock'))
  end

  def test_can_remove_registry_lock_from_a_domain
    @domain.apply_registry_lock

    visit edit_admin_domain_path(@domain)
    click_link_or_button('Actions')
    assert(page.has_link?('Remove registry lock'))

    accept_confirm('Are you sure you want to remove the registry lock?') do
      click_link_or_button('Remove registry lock')
    end

    assert_text('Registry lock removed')

    @domain.reload
    refute @domain.locked_by_registrant?
  end

  def test_cannot_remove_registry_lock_from_not_locked_domain
    @domain.apply_registry_lock
    visit edit_admin_domain_path(@domain)
    @domain.remove_registry_lock

    refute @domain.locked_by_registrant?

    click_link_or_button('Actions')
    assert(page.has_link?('Remove registry lock'))

    accept_confirm('Are you sure you want to remove the registry lock?') do
      click_link_or_button('Remove registry lock')
    end

    assert_text('Registry lock could not be removed')
    refute @domain.locked_by_registrant?
  end
end
