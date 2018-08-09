require 'test_helper'

class DomainDiscardableTest < ActiveSupport::TestCase
  setup do
    travel_to Time.zone.parse('2010-07-05 10:30')
    @domain = domains(:shop)
    @domain.delete_at = Time.zone.parse('2010-07-05 10:00')
  end

  teardown do
    travel_back
  end

  def test_discarding_a_domain_persists_the_state
    @domain.discard
    @domain.reload
    assert @domain.discarded?
  end

  def test_discarding_a_domain_schedules_deletion_at_random_time
    @domain.discard
    other_domain = domains(:airport)
    other_domain.delete_at = Time.zone.parse('2010-07-04')
    other_domain.discard

    background_job = QueJob.find_by("args->>0 = '#{@domain.id}'", job_class: DomainDeleteJob.name)
    other_background_job = QueJob.find_by("args->>0 = '#{other_domain.id}'",
                                          job_class: DomainDeleteJob.name)
    assert_not_equal background_job.run_at, other_background_job.run_at
  end

  def test_discarding_a_domain_bypasses_validation
    domain = domains(:invalid)
    domain.delete_at = Time.zone.parse('2010-07-05 10:00')
    domain.discard
    domain.reload
    assert domain.discarded?
  end

  def test_domain_cannot_be_discarded_repeatedly
    @domain.discard

    exception = assert_raises do
      @domain.discard
    end
    assert_equal 'Domain is already discarded', exception.message
  end

  def test_keeping_a_domain_bypasses_validation
    domain = domains(:invalid)
    domain.delete_at = Time.zone.parse('2010-07-05 10:00')
    domain.discard
    domain.keep
    domain.reload
    assert_not domain.discarded?
  end

  def test_keeping_a_domain_cancels_domain_deletion
    @domain.discard
    @domain.keep
    assert_nil QueJob.find_by("args->>0 = '#{@domain.id}'", job_class: DomainDeleteJob.name)
  end
end
