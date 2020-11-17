require 'application_system_test_case'

class AdminAreaDomainForceDeleteTest < ApplicationSystemTestCase
  include ActionMailer::TestHelper

  setup do
    sign_in users(:admin)
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
    assert_difference '@domain.registrar.notifications.size' do
      visit edit_admin_domain_url(@domain)
      click_link_or_button 'Force delete domain'
    end
  end

  def test_notifies_registrant_and_admin_contacts_by_email_if_fast_delete
    assert_emails 1 do
      visit edit_admin_domain_url(@domain)
      find(:css, '#soft_delete').set(false)
      click_link_or_button 'Force delete domain'
    end
  end

  def test_notifies_registrant_and_admin_contacts_by_email_if_soft_delete
    assert_emails 0 do
      visit edit_admin_domain_url(@domain)
      find(:css, '#soft_delete').set(true)
      click_link_or_button 'Force delete domain'
    end

    @domain.reload
    assert_equal @domain.notification_template, @domain.template_name
  end

  def test_uses_legal_template_if_registrant_org
    @domain.registrant.update(ident_type: 'org')

    assert_emails 0 do
      visit edit_admin_domain_url(@domain)
      find(:css, '#soft_delete').set(true)
      click_link_or_button 'Force delete domain'
    end

    @domain.reload
    assert_equal @domain.notification_template, @domain.template_name
  end

  def test_uses_legal_template_if_invalid_email
    verification = @domain.contacts.first.email_verification
    verification.update(verified_at: Time.zone.now - 1.day, success: false)

    assert_equal @domain.notification_template, 'invalid_email'

    assert_emails 0 do
      visit edit_admin_domain_url(@domain)
      find(:css, '#soft_delete').set(true)
      click_link_or_button 'Force delete domain'
    end

    @domain.reload
    assert_equal @domain.notification_template, @domain.template_name
  end

  def test_allows_to_skip_notifying_registrant_and_admin_contacts_by_email
    assert_no_emails do
      visit edit_admin_domain_url(@domain)
      uncheck 'notify_by_email'
      click_link_or_button 'Force delete domain'
    end
  end

  def test_cancels_scheduled_domain_force_delete
    @domain.schedule_force_delete

    visit edit_admin_domain_url(@domain)
    click_link_or_button 'Cancel force delete'
    @domain.reload

    refute @domain.force_delete_scheduled?
    assert_current_path edit_admin_domain_path(@domain)
    assert_text 'Force delete procedure has been cancelled'
  end

  def test_force_delete_procedure_cannot_be_scheduled_on_a_discarded_domain
    @domain.update!(statuses: [DomainStatus::DELETE_CANDIDATE])

    visit edit_admin_domain_url(@domain)
    assert_no_button 'Schedule force delete'
    assert_no_link 'Schedule force delete'
  end
end
