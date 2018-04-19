require 'test_helper'

class DomainDiscardableTest < ActiveSupport::TestCase
  setup do
    @domain = domains(:shop)
  end

  def test_discarding_a_domain
    @domain.discard
    @domain.reload
    assert @domain.discarded?
  end

  def test_discarding_a_domain_deletes_schedules_domain_deletion
    @domain.discard
    assert QueJob.find_by("args->>0 = '#{@domain.id}'", job_class: DomainDeleteJob.name)
  end

  def test_discarding_a_domain_bypasses_validation
    domain = domains(:invalid)
    domain.discard
    domain.reload
    assert domain.discarded?
  end

  def test_keeping_a_domain_bypasses_validation
    domain = domains(:invalid)
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
