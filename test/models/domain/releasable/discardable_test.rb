require 'test_helper'
require 'sidekiq/testing'
Sidekiq::Testing.fake!

class DomainReleasableDiscardableTest < ActiveSupport::TestCase
  include ActiveJob::TestHelper

  setup do
    ActiveJob::Base.queue_adapter = :test
    @domain = domains(:shop)
  end

  def test_discards_domains_with_past_delete_date
    @domain.update!(delete_date: '2010-07-04')
    travel_to Time.zone.parse('2010-07-05')

    Domain.release_domains
    @domain.reload

    assert @domain.discarded?
  end

  def test_discards_domains_with_scheduled_force_delete_procedure
    @domain.update!(force_delete_date: '2010-07-05')
    travel_to Time.zone.parse('2010-07-05')

    Domain.release_domains
    @domain.reload

    assert @domain.discarded?
  end

  def test_ignores_domains_with_delete_date_in_the_future
    @domain.update!(delete_date: '2010-07-06')
    travel_to Time.zone.parse('2010-07-05')

    Domain.release_domains
    @domain.reload

    assert_not @domain.discarded?
  end

  def test_ignores_already_discarded_domains
    @domain.update!(delete_date:'2010-07-05')
    travel_to Time.zone.parse('2010-07-05')

    Domain.release_domains

    assert_no_enqueued_jobs do
      Domain.release_domains
    end
  end

  def test_does_not_ignore_domains_with_server_delete_prohibited_status
    @domain.update!(delete_date: '2010-07-04', statuses: [DomainStatus::SERVER_DELETE_PROHIBITED])
    travel_to Time.zone.parse('2010-07-05')

    Domain.release_domains
    @domain.reload

    assert @domain.discarded?
  end

  def test_ignores_domains_with_server_release_prohibited_status
    @domain.update!(delete_date: '2010-07-04', statuses: [DomainStatus::SERVER_RELEASE_PROHIBITED])
    travel_to Time.zone.parse('2010-07-05')

    Domain.release_domains
    @domain.reload

    assert_not @domain.discarded?
  end

  def test_discarding_a_domain_schedules_deletion_at_random_time
    travel_to Time.zone.parse('2010-07-05')

    @domain.update_columns(delete_date: '2010-07-05')

    assert_enqueued_with(job: DomainDeleteJob) do
      Domain.release_domains
    end

    other_domain = domains(:airport)
    other_domain.update_columns(delete_date: '2010-07-05')
    assert_enqueued_with(job: DomainDeleteJob) do
      Domain.release_domains
    end

    assert_not other_domain.deletion_time == @domain.deletion_time
  end

  def test_discarding_a_domain_bypasses_validation
    domain = domains(:invalid)
    domain.update_columns(delete_date: '2010-07-04')
    travel_to Time.zone.parse('2010-07-05')

    Domain.release_domains
    domain.reload

    assert domain.discarded?
  end

  def test_keeping_a_domain_bypasses_validation
    domain = domains(:invalid)
    domain.update_columns(statuses: [DomainStatus::DELETE_CANDIDATE])

    domain.keep
    domain.reload

    assert_not domain.discarded?
  end

  def test_keeping_a_domain_cancels_domain_deletion
    @domain.update!(statuses: [DomainStatus::DELETE_CANDIDATE])
    assert_no_enqueued_jobs only: DomainDeleteJob do
      @domain.keep
    end
  end
end
