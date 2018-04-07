require 'test_helper'

class DiscardDomainTaskTest < ActiveSupport::TestCase
  setup do
    travel_to Time.zone.parse('2010-07-05 08:00')
    @domain = domains(:shop)
  end

  def test_discard_domains_with_past_delete_at
    @domain.update!(delete_at: Time.zone.parse('2010-07-05 07:59'))
    Rake::Task['domain:discard'].execute
    @domain.reload
    assert @domain.discarded?
  end

  def test_ignore_domains_with_delete_at_in_the_future_or_now
    @domain.update!(delete_at: Time.zone.parse('2010-07-05 08:00'))
    Rake::Task['domain:discard'].execute
    @domain.reload
    refute @domain.discarded?
  end

  def test_ignore_already_discarded_domains
    @domain.update!(delete_at: Time.zone.parse('2010-07-05 07:59'))
    @domain.discard

    job_count = lambda do
      QueJob.where("args->>0 = '#{@domain.id}'", job_class: DomainDeleteJob.name).count
    end

    assert_no_difference job_count, 'A domain should not be discarded again' do
      Rake::Task['domain:discard'].execute
    end
  end

  def test_ignore_domains_with_server_delete_prohibited_status
    @domain.update!(delete_at: Time.zone.parse('2010-07-05 07:59'),
                    statuses: [DomainStatus::SERVER_DELETE_PROHIBITED])
    Rake::Task['domain:discard'].execute
    @domain.reload
    refute @domain.discarded?
  end
end
