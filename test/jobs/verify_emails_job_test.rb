require "test_helper"

class VerifyEmailsJobTest < ActiveJob::TestCase
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

  def test_job_checks_if_email_valid
    perform_enqueued_jobs do
      VerifyEmailsJob.perform_now(@contact_verification.id)
    end
    @contact_verification.reload

    assert @contact_verification.success
  end

  def test_job_checks_does_not_run_if_recent
    old_verified_at = Time.zone.now - 10.days
    @contact_verification.update(success: true, verified_at: old_verified_at)
    assert @contact_verification.recently_verified?

    perform_enqueued_jobs do
      VerifyEmailsJob.perform_now(@contact_verification.id)
    end
    @contact_verification.reload

    assert_in_delta @contact_verification.verified_at.to_i, old_verified_at.to_i, 1
  end

  def test_job_checks_if_email_invalid
    perform_enqueued_jobs do
      VerifyEmailsJob.perform_now(@invalid_contact_verification.id)
    end
    @contact_verification.reload

    refute @contact_verification.success
  end
end
