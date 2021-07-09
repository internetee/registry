require 'test_helper'

class MigrateBeforeForceDeleteStatusesJobTest < ActiveJob::TestCase
  setup do
    travel_to Time.zone.parse('2010-07-05')
    @domain = domains(:shop)
  end

  def test_migrate_statuses_to_domain_history_job
    @domain.update(statuses: [DomainStatus::SERVER_UPDATE_PROHIBITED])
    @domain.reload
    assert @domain.statuses.include? DomainStatus::SERVER_UPDATE_PROHIBITED

    perform_enqueued_jobs do
      MigrateStatusesToDomainHistoryJob.perform_later
    end

    @domain.reload

    assert @domain.admin_store_statuses_history.include? DomainStatus::SERVER_UPDATE_PROHIBITED
  end
end
