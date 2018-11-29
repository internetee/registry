require 'test_helper'

class DomainReleasableDiscardableTest < ActiveSupport::TestCase
  setup do
    @domain = domains(:shop)
  end

  def test_discards_domains_with_past_delete_at
    @domain.update!(delete_at: Time.zone.parse('2010-07-05 07:59'))
    travel_to Time.zone.parse('2010-07-05 08:00')

    Domain.release_domains
    @domain.reload

    assert @domain.discarded?
  end

  def test_ignores_domains_with_delete_at_in_the_future_or_now
    @domain.update!(delete_at: Time.zone.parse('2010-07-05 08:00'))
    travel_to Time.zone.parse('2010-07-05 08:00')

    Domain.release_domains
    @domain.reload

    assert_not @domain.discarded?
  end

  def test_ignores_already_discarded_domains
    @domain.update!(delete_at: Time.zone.parse('2010-07-05 07:59'))
    travel_to Time.zone.parse('2010-07-05 08:00')

    Domain.release_domains

    job_count = lambda do
      QueJob.where("args->>0 = '#{@domain.id}'", job_class: DomainDeleteJob.name).count
    end

    assert_no_difference job_count, 'A domain should not be discarded again' do
      Domain.release_domains
    end
  end

  def test_ignores_domains_with_server_delete_prohibited_status
    @domain.update!(delete_at: Time.zone.parse('2010-07-05 07:59'),
                    statuses: [DomainStatus::SERVER_DELETE_PROHIBITED])
    travel_to Time.zone.parse('2010-07-05 08:00')

    Domain.release_domains
    @domain.reload

    assert_not @domain.discarded?
  end
end
