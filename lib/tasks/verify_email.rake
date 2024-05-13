require 'optparse'
require 'rake_option_parser_boilerplate'
require 'syslog/logger'
require 'active_record'

SPAM_PROTECT_TIMEOUT = 30.seconds
PATCH_SIZE = 10
PATCH_INTERVAL = 10.minutes

namespace :verify_email do
  # bundle exec rake verify_email:check_all -- --check_level=mx --spam_protect=true
  # bundle exec rake verify_email:check_all -- -d shop.test -c mx -s true
  # bunlde exec rake verify_email:check_all -- -e email1@example.com,email2@example.com -c mx
  # bundle exec rake verify_email:check_all -- --email_regex='^test\d*@example\.com$' --check_level=mx --spam_protect=true
  desc 'Starts verifying email jobs with optional check level and spam protection'
  task check_all: :environment do
    options = {
      domain_name: nil,
      check_level: 'mx',
      spam_protect: false,
      emails: [],
      email_regex: nil,
      force: false
    }

    banner = 'Usage: rake verify_email:check_all -- [options]'
    options = RakeOptionParserBoilerplate.process_args(options: options,
                                                       banner: banner,
                                                       hash: opts_hash)

    ValidationEvent.old_records.destroy_all
    email_contacts = prepare_contacts(options)
    enqueue_email_verification(email_contacts, options)
  end
end

def enqueue_email_verification(email_contacts, options)
  email_contacts.each_slice(PATCH_SIZE).with_index do |slice, index|
    slice.each do |email|
      VerifyEmailsJob.set(wait: spam_protect_timeout(options) + index * PATCH_INTERVAL)
                     .perform_later(email: email, check_level: options[:check_level], force: options[:force])
    end
  end
end

def spam_protect_timeout(options)
  options[:spam_protect] ? 0.seconds : SPAM_PROTECT_TIMEOUT
end

def prepare_contacts(options)
  if options[:emails].any?
    options[:emails]
  elsif options[:email_regex].present?
    contacts_by_regex(options[:email_regex])
  elsif options[:domain_name].present?
    contacts_by_domain(options[:domain_name])
  else
    unvalidated_and_failed_contacts_emails
  end
end

def unvalidated_and_failed_contacts_emails
  time = Time.zone.now - ValidationEvent::VALIDATION_PERIOD
  validation_events_ids = ValidationEvent.where('created_at >= ?', time)
                                         .distinct.pluck(:validation_eventable_id)
  unvalidated_contacts_emails = Contact.where.not(id: validation_events_ids).pluck(:email)
  (unvalidated_contacts_emails + failed_contacts_emails).uniq
end

def failed_contacts_emails(emails: [])
  failed_validations_ids = ValidationEvent.failed.distinct.pluck(:validation_eventable_id)

  Contact.where(id: failed_validations_ids).find_each(batch_size: 10_000) do |contact|
    emails << contact.email
  end

  emails.uniq
end

def contacts_by_domain(domain_name)
  domain = ::Domain.find_by(name: domain_name)
  return unless domain

  domain.contacts.pluck(:email).uniq
end

def contacts_by_regex(regex)
  Contact.where('email ~ ?', regex).pluck(:email).uniq
end

def opts_hash
  {
    domain_name: ['-d [DOMAIN_NAME]', '--domain_name [DOMAIN_NAME]', String],
    check_level: ['-c [CHECK_LEVEL]', '--check_level [CHECK_LEVEL]', String],
    spam_protect: ['-s [SPAM_PROTECT]', '--spam_protect [SPAM_PROTECT]', FalseClass],
    emails: ['-e [EMAILS]', '--emails [EMAILS]', Array],
    email_regex: ['-r [EMAIL_REGEX]', '--email_regex [EMAIL_REGEX]', String],
    force: ['-f', '--force', FalseClass]
  }
end
