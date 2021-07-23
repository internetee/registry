require 'test_helper'

class MigrateBeforeForceDeleteStatusesJobTest < ActiveJob::TestCase
  setup do
    travel_to Time.zone.parse('2010-07-05')
    @domain = domains(:shop)
  end

  def test_migrate_data_before_force_delete
    @domain.update(statuses: [DomainStatus::SERVER_UPDATE_PROHIBITED])
    @domain.reload
    assert @domain.statuses.include? DomainStatus::SERVER_UPDATE_PROHIBITED

    @domain.schedule_force_delete(type: :soft)
    @domain.reload

    assert @domain.force_delete_scheduled?

    perform_enqueued_jobs do
      MigrateBeforeForceDeleteStatusesJob.perform_later
    end

    @domain.reload

    assert @domain.force_delete_domain_statuses_history.include? DomainStatus::SERVER_UPDATE_PROHIBITED
  end
end
