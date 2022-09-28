require 'optparse'
require 'rake_option_parser_boilerplate'
require 'syslog/logger'
require 'active_record'

namespace :verify_email do
  # bundle exec rake verify_email:check_all -- --check_level=mx --spam_protect=true
  # bundle exec rake verify_email:check_all -- -dshop.test -cmx -strue
  desc 'Starts verifying email jobs with optional check level and spam protection'
  task check_all: :environment do
    SPAM_PROTECT_TIMEOUT = 30.seconds
    options = {
      domain_name: nil,
      check_level: 'mx',
      spam_protect: false,
    }
    banner = 'Usage: rake verify_email:check_all -- [options]'
    options = RakeOptionParserBoilerplate.process_args(options: options,
                                                       banner: banner,
                                                       hash: opts_hash)
    ValidationEvent.old_records.destroy_all
    email_contacts = prepare_contacts(options)
    email_contacts.each do |email|
      VerifyEmailsJob.set(wait_until: spam_protect_timeout(options))
                     .perform_later(email: email, check_level: check_level(options))
    end
  end
end

def check_level(options)
  options[:check_level]
end

def spam_protect(options)
  options[:spam_protect]
end

def spam_protect_timeout(options)
  spam_protect(options) ? 0.seconds : SPAM_PROTECT_TIMEOUT
end

def prepare_contacts(options)
  if options[:domain_name].present?
    contacts_by_domain(options[:domain_name])
  else
    time = Time.zone.now - ValidationEvent::VALIDATION_PERIOD
    validation_events_ids = ValidationEvent.where('created_at > ?', time).distinct.pluck(:validation_eventable_id)

    contacts_emails = Contact.where.not(id: validation_events_ids).pluck(:email)
    (contacts_emails + failed_email_contacts).uniq
  end
end

def failed_email_contacts
  failed_contacts = []
  failed_validations_ids = ValidationEvent.failed.distinct.pluck(:validation_eventable_id)
  contacts = Contact.where(id: failed_validations_ids).includes(:validation_events)
  contacts.find_each(batch_size: 10_000) do |contact|
    failed_contacts << contact.email
  end

  failed_contacts.uniq
end

def contacts_by_domain(domain_name)
  domain = ::Domain.find_by(name: domain_name)
  return unless domain

  domain.contacts.pluck(:email).uniq
end

def opts_hash
  {
    domain_name: ['-d [DOMAIN_NAME]', '--domain_name [DOMAIN_NAME]', String],
    check_level: ['-c [CHECK_LEVEL]', '--check_level [CHECK_LEVEL]', String],
    spam_protect: ['-s [SPAM_PROTECT]', '--spam_protect [SPAM_PROTECT]', FalseClass],
  }
end
