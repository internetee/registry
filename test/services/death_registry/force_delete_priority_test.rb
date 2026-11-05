require 'test_helper'

class DeathRegistryForceDeletePriorityTest < ActiveSupport::TestCase
  setup do
    @domain = domains(:shop)
    @domain.update_columns(valid_to: Time.zone.today + 3.years + 1.month, statuses: [DomainStatus::OK])
    @original_statuses = @domain.statuses.dup
    ValidationEvent.destroy_all
  end

  def test_takes_priority_without_force_delete
    assert priority.takes_priority?
  end

  def test_takes_priority_over_force_delete_with_later_purge_date
    schedule_invalid_email_force_delete

    assert priority.takes_priority?
  end

  def test_does_not_take_priority_over_force_delete_with_earlier_purge_date
    @domain.reload.schedule_force_delete(type: :fast_track, reason: 'invalid_company')

    assert_not priority.takes_priority?
  end

  def test_replaces_force_delete_and_keeps_original_statuses
    schedule_invalid_email_force_delete

    schedule_death_force_delete
    @domain.reload

    assert_equal 'deceased_person', @domain.template_name
    assert_equal 'fast_track', @domain.force_delete_type
    assert_equal Time.zone.tomorrow, @domain.force_delete_start.to_date
    assert_equal @original_statuses, @domain.force_delete_domain_statuses_history
    previous = JSON.parse(@domain.force_delete_data['previous_force_delete'])
    assert_equal 'invalid_email', previous['force_delete_data']['template_name']
  end

  def test_restores_replaced_force_delete_when_its_reason_exists
    schedule_invalid_email_force_delete
    previous_start = @domain.reload.force_delete_start
    schedule_death_force_delete

    assert_equal :restored, priority.stop

    @domain.reload
    assert_equal 'invalid_email', @domain.template_name
    assert_equal 'soft', @domain.force_delete_type
    assert_equal previous_start, @domain.force_delete_start
    assert_equal 'invalid@inbox.test', @domain.status_notes[DomainStatus::FORCE_DELETE]
    assert_equal @original_statuses, @domain.force_delete_domain_statuses_history
    assert_nil @domain.force_delete_data['previous_force_delete']
    assert_not_includes @domain.statuses, DomainStatus::CLIENT_HOLD
    assert Notification.where('text LIKE ?', "Force delete because of the registrant's death was stopped " \
                                             'on domain shop.test. The earlier force delete continues: ' \
                                             'invalid_email.%').exists?
  end

  def test_cancels_both_force_deletes_when_replaced_reason_is_gone
    schedule_invalid_email_force_delete
    schedule_death_force_delete
    ValidationEvent.destroy_all

    assert_equal :cancelled, priority.stop

    @domain.reload
    assert_not @domain.force_delete_scheduled?
    assert_equal @original_statuses, @domain.statuses
  end

  def test_always_restores_manual_force_delete
    @domain.reload.schedule_force_delete(type: :soft)
    @domain.reload.update_columns(status_notes: { DomainStatus::FORCE_DELETE => 'Manual' })
    schedule_death_force_delete

    assert_equal :restored, priority.stop

    assert_equal 'Manual', @domain.reload.status_notes[DomainStatus::FORCE_DELETE]
    assert_equal 'soft', @domain.force_delete_type
  end

  def test_restored_force_delete_past_outzone_date_takes_domain_out_of_zone_at_once
    @domain.update_columns(valid_to: Time.zone.today + 1.year + 1.month)
    schedule_invalid_email_force_delete
    schedule_death_force_delete

    travel_to @domain.reload.valid_to - 1.year + Setting.expire_warning_period.days + 1.day do
      priority.stop
    end

    assert_includes @domain.reload.statuses, DomainStatus::CLIENT_HOLD
  end

  def test_cancels_when_nothing_was_replaced
    schedule_death_force_delete

    assert_equal :cancelled, priority.stop
    assert_not @domain.reload.force_delete_scheduled?
  end

  def test_registrant_change_cancels_both_force_deletes
    schedule_invalid_email_force_delete
    schedule_death_force_delete

    @domain.reload
    @domain.registrant = contacts(:william).becomes(Registrant)
    @domain.save!(validate: false)

    @domain.reload
    assert_not @domain.force_delete_scheduled?
    assert_nil @domain.force_delete_data
  end

  private

  def priority
    DeathRegistry::ForceDeletePriority.new(@domain.reload)
  end

  def schedule_invalid_email_force_delete
    contact = @domain.admin_contacts.first
    contact.update_columns(email: 'invalid@inbox.test')
    ValidationEvent.create!(validation_eventable: contact, success: false, event_type: 'email_validation',
                            event_data: { 'check_level' => 'regex', 'email' => contact.email })
    @domain.reload.schedule_force_delete(type: :soft, notify_by_email: true, reason: 'invalid_email',
                                         email: contact.email)
    assert_equal 'invalid_email', @domain.reload.template_name
  end

  def schedule_death_force_delete
    domain = @domain.reload
    result = DeathRegistry::ForceDeletePriority.new(domain).replace_current_force_delete do
      domain.schedule_force_delete(type: :fast_track, notify_by_email: true, reason: 'deceased_person',
                                   notes: 'Deceased registrant')
    end
    assert result.valid?
  end
end
