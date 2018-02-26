require 'test_helper'

class AdminAreaDomainForceDeleteTest < ActionDispatch::IntegrationTest
  include ActionMailer::TestHelper

  def setup
    login_as users(:admin)
    @domain = domains(:shop)
    ActionMailer::Base.deliveries.clear
  end

  def test_schedules_domain_force_delete
    refute @domain.force_delete_scheduled?

    visit edit_admin_domain_url(@domain)
    click_link_or_button 'Force delete domain'
    @domain.reload

    assert @domain.force_delete_scheduled?
    assert_current_path edit_admin_domain_path(@domain)
    assert_text 'Force delete procedure has been scheduled'
  end

  def test_notifies_registrar
    assert_difference '@domain.registrar.messages.size' do
      visit edit_admin_domain_url(@domain)
      click_link_or_button 'Force delete domain'
    end
  end

  def test_notifies_registrant_and_admin_contacts_by_email_by_default
    assert_emails 1 do
      visit edit_admin_domain_url(@domain)
      click_link_or_button 'Force delete domain'
    end
  end

  def test_allows_to_skip_notifying_registrant_and_admin_contacts_by_email
    assert_no_emails do
      visit edit_admin_domain_url(@domain)
      uncheck 'notify_by_email'
      click_link_or_button 'Force delete domain'
    end
  end

  def test_cancels_scheduled_domain_force_delete
    @domain.update_attribute(:statuses, [DomainStatus::FORCE_DELETE])
    assert @domain.force_delete_scheduled?

    visit edit_admin_domain_url(@domain)
    click_link_or_button 'Cancel force delete'
    @domain.reload

    refute @domain.force_delete_scheduled?
    assert_current_path edit_admin_domain_path(@domain)
    assert_text 'Force delete procedure has been cancelled'
  end
end
