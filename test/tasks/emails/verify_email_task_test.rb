require 'test_helper'

class VerifyEmailTaskTest < ActiveJob::TestCase

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

  def test_tasks_verifies_emails
    capture_io { run_task }

    assert ValidationEvent.validated_ids_by(Contact).include? @contact.id
    assert @contact.validation_events.last.success
    refute @invalid_contact.validation_events.last.success
    refute ValidationEvent.validated_ids_by(Contact).include? @invalid_contact.id
  end

  def run_task
    perform_enqueued_jobs do
      Rake::Task['verify_email:check_all'].execute
    end
  end
end
