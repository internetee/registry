require 'test_helper'

class AdminDomainsTestTest < ApplicationSystemTestCase
  setup do
    sign_in users(:admin)
    @domain = domains(:shop)
  end

  teardown do
    travel_back
  end

  def test_shows_details
    visit admin_domain_path(@domain)
    assert_field nil, with: @domain.transfer_code
  end

  def test_keep_a_domain
    travel_to Time.zone.parse('2010-07-05 10:30')
    @domain.delete_at = Time.zone.parse('2010-07-05 10:00')
    @domain.discard

    visit edit_admin_domain_url(@domain)
    click_link_or_button 'Remove deleteCandidate status'
    @domain.reload

    assert_not @domain.discarded?
    assert_text 'deleteCandidate status has been removed'
    assert_no_link 'Remove deleteCandidate status'
  end
end
