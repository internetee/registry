require 'test_helper'

class ReplaceUpdToObjUpdProhibitedJobTest < ActiveSupport::TestCase
  include ActiveJob::TestHelper

  setup do
    travel_to Time.zone.parse('2010-07-05')
    @domain = domains(:shop)
  end

  def test_start_adding_new_status_for_locked_domains
    @domain.apply_registry_lock
    assert @domain.locked_by_registrant?

    perform_enqueued_jobs do
      ReplaceUpdToObjUpdProhibitedJob.perform_later('add')
    end

    @domain.reload
    assert @domain.statuses.include? "serverObjUpdateProhibited"
  end

  def test_start_adding_new_status_for_locked_domains
    @domain.apply_registry_lock
    assert @domain.locked_by_registrant?
    assert @domain.statuses.include? "serverUpdateProhibited"

    @domain.statuses += ["serverObjUpdateProhibited"]
    @domain.save
    @domain.reload

    assert @domain.statuses.include? "serverObjUpdateProhibited"

    perform_enqueued_jobs do
      ReplaceUpdToObjUpdProhibitedJob.perform_later('remove')
    end

    @domain.reload

    assert_not @domain.statuses.include? "serverUpdateProhibited"
  end

  def test_should_not_added_to_non_locked_domain_with_update_prohibited
    @domain.statuses += ["serverUpdateProhibited"]
    @domain.save
    @domain.reload
    assert @domain.statuses.include? "serverUpdateProhibited"

    assert_not @domain.locked_by_registrant?

    perform_enqueued_jobs do
      ReplaceUpdToObjUpdProhibitedJob.perform_later('add')
    end

    assert_not @domain.statuses.include? "serverObjUpdateProhibited"
  end

  def test_should_not_removed_from_non_locked_domain_with_update_prohibited
    @domain.statuses += ["serverUpdateProhibited"]
    @domain.save
    @domain.reload
    assert @domain.statuses.include? "serverUpdateProhibited"

    assert_not @domain.locked_by_registrant?

    perform_enqueued_jobs do
      ReplaceUpdToObjUpdProhibitedJob.perform_later('remove')
    end

    assert @domain.statuses.include? "serverUpdateProhibited"
  end
end