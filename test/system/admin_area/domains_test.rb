require 'test_helper'

class AdminDomainsTestTest < ApplicationSystemTestCase
  setup do
    sign_in users(:admin)
    travel_to Time.zone.parse('2010-07-05 00:30:00')
    @domain = domains(:shop)
  end

  teardown do
    travel_back
  end

  def test_shows_details
    visit admin_domain_path(@domain)
    assert_field nil, with: @domain.transfer_code
  end

  def test_admin_registry_lock_date
    visit admin_domain_path(@domain)
    refute_text 'Registry lock time 2010-07-05 00:30'

    lockable_domain = domains(:airport)
    lockable_domain.apply_registry_lock

    visit admin_domain_path(lockable_domain)
    assert_text 'Registry lock time 2010-07-05 00:30'
    assert_text 'registryLock'
  end
end
