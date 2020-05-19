require 'application_system_test_case'
require 'test_helper'

class AdminDisputesSystemTest < ApplicationSystemTestCase
  include ActionView::Helpers::NumberHelper

  setup do
    @dispute = disputes(:active)
    @original_default_language = Setting.default_language
    sign_in users(:admin)
  end

  teardown do
    Setting.default_language = @original_default_language
  end

  def test_creates_new_dispute
    assert_nil Dispute.active.find_by(domain_name: 'hospital.test')

    visit admin_disputes_path
    click_on 'New disputed domain'

    fill_in 'Domain name', with: 'hospital.test'
    fill_in 'Password', with: '1234'
    fill_in 'Starts at', with: (Time.zone.today - 2.years).to_s
    fill_in 'Comment', with: 'Sample comment'
    click_on 'Save'

    assert_text 'Dispute was successfully created.'
    assert_text 'hospital.test'
  end

  def test_creates_new_dispute_for_unregistered_domain
    assert_nil Dispute.active.find_by(domain_name: 'nonexistant.test')

    visit admin_disputes_path
    click_on 'New disputed domain'

    fill_in 'Domain name', with: 'nonexistant.test'
    fill_in 'Password', with: '1234'
    fill_in 'Starts at', with: Time.zone.today.to_s
    fill_in 'Comment', with: 'Sample comment'
    click_on 'Save'

    assert_text 'Dispute was successfully created for domain that is not registered.'
    assert_text 'nonexistant.test'
  end

  def test_throws_error_if_starts_at_is_in_future
    assert_nil Dispute.active.find_by(domain_name: 'disputed.test')

    visit admin_disputes_path
    click_on 'New disputed domain'

    fill_in 'Domain name', with: 'disputed.test'
    fill_in 'Password', with: '1234'
    fill_in 'Starts at', with: (Time.zone.today + 2.day).to_s
    fill_in 'Comment', with: 'Sample comment'
    click_on 'Save'

    assert_text "Can not be greater than today's date"
  end

  def test_updates_dispute
    assert_not_equal Time.zone.today, @dispute.starts_at

    visit edit_admin_dispute_path(@dispute)
    fill_in 'Starts at', with: Time.zone.today.to_s
    click_link_or_button 'Save'

    assert_text 'Dispute was successfully updated'
    assert_text Time.zone.today
  end

  def test_deletes_dispute
    visit delete_admin_dispute_path(@dispute)

    assert_text 'Dispute was successfully closed.'
  end

  def test_can_not_create_overlapping_dispute
    visit admin_disputes_path
    click_on 'New disputed domain'

    fill_in 'Domain name', with: 'active-dispute.test'
    fill_in 'Starts at', with: @dispute.starts_at + 1.day
    click_on 'Save'

    assert_text 'Dispute already exists for this domain at given timeframe'
  end
end
