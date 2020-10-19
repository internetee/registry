require 'test_helper'

class VerifyEmailTaskTest < ActiveJob::TestCase

  def setup
    @contact = contacts(:john)
    @invalid_contact = contacts(:invalid_email)
    @contact_verification = @contact.email_verification
    @invalid_contact_verification = @invalid_contact.email_verification

    @default_whitelist = Truemail.configure.whitelisted_domains
    @default_blacklist = Truemail.configure.blacklisted_domains
    Truemail.configure.whitelisted_domains = whitelisted_domains
    Truemail.configure.blacklisted_domains = blacklisted_domains
  end

  def teardown
    Truemail.configure.whitelisted_domains = @default_whitelist
    Truemail.configure.blacklisted_domains = @default_blacklist
  end

  def domain(email)
    Mail::Address.new(email).domain
  rescue Mail::Field::IncompleteParseError
    nil
  end

  def whitelisted_domains
    [domain(@contact.email)].reject(&:blank?)
  end

  def blacklisted_domains
    [domain(@invalid_contact.email)].reject(&:blank?)
  end

  def test_tasks_verifies_emails
    capture_io { run_task }

    @contact_verification.reload
    @invalid_contact_verification.reload

    assert @contact_verification.verified?
    assert @invalid_contact_verification.failed?
  end

  def test_domain_task_verifies_for_one_domain
    capture_io { run_single_domain_task(@contact_verification.domain) }

    @contact_verification.reload
    @invalid_contact_verification.reload

    assert @contact_verification.verified?
    assert @invalid_contact_verification.not_verified?
  end

  def run_task
    perform_enqueued_jobs do
      Rake::Task['verify_email:all_domains'].execute
    end
  end

  def run_single_domain_task(domain)
    perform_enqueued_jobs do
      Rake::Task["verify_email:domain"].invoke(domain)
    end
  end
end
