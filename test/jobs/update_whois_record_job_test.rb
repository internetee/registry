require 'test_helper'

class SendEInvoiceJobTest < ActiveJob::TestCase

  def test_job_is_updating_domains
    domain_names = Domain.find_in_batches.first.map(&:name)
    assert_domains_processed_by_task(domain_names, 'domain')
  end

  def test_job_is_updating_blocked_domains
    domain_names = BlockedDomain.find_in_batches.first.map(&:name)
    assert_domains_processed_by_task(domain_names, 'blocked')
  end

  def test_job_is_updating_reserved_domains
    domain_names = ReservedDomain.find_in_batches.first.map(&:name)
    assert_domains_processed_by_task(domain_names, 'reserved')
  end

  private

  def assert_domains_processed_by_task(domain_names, type)
    Rake::Task['whois:regenerate'].execute

    perform_enqueued_jobs
    assert_performed_with(job: UpdateWhoisRecordJob, args: [domain_names, type])
  end
end
