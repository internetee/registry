require 'test_helper'

class DomainDeletableTest < ActiveSupport::TestCase
  setup do
    @domain = domains(:shop)
  end

  def test_discard_domain
    @domain.discard
    @domain.reload
    assert QueJob.find_by("args->>0 = '#{@domain.id}'", job_class: DomainDeleteJob.name)
    assert @domain.discarded?
  end

  def test_discard_invalid_domain
    domain = domains(:invalid)
    domain.discard
    domain.reload
    assert domain.discarded?, 'a domain should be discarded'
  end

  def test_keep_domain
    @domain.discard
    @domain.keep
    @domain.reload
    assert_nil QueJob.find_by("args->>0 = '#{@domain.id}'", job_class: DomainDeleteJob.name)
    refute @domain.discarded?
  end
end
