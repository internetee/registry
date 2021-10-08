require "test_helper"

class VerifyEmailsJobTest < ActiveJob::TestCase
  def setup
    @contact = contacts(:john)
    @invalid_contact = contacts(:invalid_email)
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
    assert_difference 'ValidationEvent.successful.count', 1 do
      perform_enqueued_jobs do
        VerifyEmailsJob.perform_now(contact_id: @contact.id, check_level: 'regex')
      end
    end
    assert ValidationEvent.validated_ids_by(Contact).include? @contact.id
  end

  def test_job_checks_if_email_invalid
    perform_enqueued_jobs do
      VerifyEmailsJob.perform_now(contact_id: @invalid_contact.id, check_level: 'regex')
    end
    @invalid_contact.reload

    refute @invalid_contact.validation_events.last.success
    refute ValidationEvent.validated_ids_by(Contact).include? @invalid_contact.id
  end
end
