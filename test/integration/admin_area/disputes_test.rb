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
    fill_in 'Comment', with: 'Sample comment'
    click_on 'Save'

    assert_text 'Dispute was successfully created for domain that is not registered.'
    assert_text 'nonexistant.test'
  end

  def test_updates_dispute
    assert_not_equal Time.zone.today, @dispute.starts_at

    visit edit_admin_dispute_path(@dispute)
    fill_in 'Comment', with: 'Sample comment with new text'
    click_link_or_button 'Save'

    assert_text 'Dispute was successfully updated'
  end

  def test_deletes_dispute
    visit delete_admin_dispute_path(@dispute)

    assert_text 'Dispute was successfully closed.'
  end

  def test_can_not_create_overlapping_dispute
    travel_to @dispute.starts_at + 1.day
    visit admin_disputes_path
    click_on 'New disputed domain'

    fill_in 'Domain name', with: 'active-dispute.test'
    click_on 'Save'

    assert_text 'Dispute already exists for this domain at given timeframe'
  end

  def test_download_disputes
    now = Time.zone.parse('2010-07-05 08:00')
    travel_to now

    get admin_disputes_path(format: :csv)

    assert_response :ok
    assert_equal 'text/csv; charset=utf-8', response.headers['Content-Type']
    assert_equal %(attachment; filename="disputes_#{Time.zone.now.to_formatted_s(:number)}.csv"; filename*=UTF-8''disputes_#{Time.zone.now.to_formatted_s(:number)}.csv),
                 response.headers['Content-Disposition']
    assert_not_empty response.body
  end
end
