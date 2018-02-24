require 'test_helper'

class AdminAreaDomainForceDeleteTest < ActionDispatch::IntegrationTest
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
    assert_equal 1, ActionMailer::Base.deliveries.size
    assert_text 'Force delete procedure has been scheduled'
  end

  def test_cancels_scheduled_domain_force_delete
    @domain.update_attribute(:statuses, [DomainStatus::FORCE_DELETE])
    assert @domain.force_delete_scheduled?

    visit edit_admin_domain_url(@domain)
    click_link_or_button 'Cancel force delete'
    @domain.reload

    refute @domain.force_delete_scheduled?
    assert_text 'Force delete procedure has been cancelled'
  end
end
