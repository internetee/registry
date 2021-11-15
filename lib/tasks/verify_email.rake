require 'optparse'
require 'rake_option_parser_boilerplate'
require 'syslog/logger'

namespace :verify_email do
  # bundle exec rake verify_email:check_all -- --domain_name=shop.test --check_level=mx --spam_protect=true
  # bundle exec rake verify_email:check_all -- -dshop.test -cmx -strue
  desc 'Starts verifying email jobs with optional check level and spam protection'
  task check_all: :environment do
    SPAM_PROTECT_TIMEOUT = 30.seconds
    options = {
      domain_name: nil,
      check_level: 'regex',
      spam_protect: false,
    }
    banner = 'Usage: rake verify_email:check_all -- [options]'
    options = RakeOptionParserBoilerplate.process_args(options: options,
                                                       banner: banner,
                                                       hash: opts_hash)

    contacts = prepare_contacts(options)
    logger.info 'No contacts to check email selected' and next if contacts.blank?

    contacts.each do |contact|
      VerifyEmailsJob.set(wait_until: spam_protect_timeout(options)).perform_later(
        contact_id: contact.id,
        check_level: check_level(options)
      )
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

def logger
  @logger ||= ActiveSupport::TaggedLogging.new(Syslog::Logger.new('registry'))
end

# Here I set the time after which the validation is considered obsolete
# I take all contact records that have successfully passed the verification and fall within the deadline
# I am looking for contacts that have not been verified or their verification is out of date

def prepare_contacts(options)
  if options[:domain_name].present?
    contacts_by_domain(options[:domain_name])
  else
    time = Time.zone.now - ValidationEvent::VALIDATION_PERIOD
    validation_events_ids = ValidationEvent.where('created_at > ?', time).pluck(:validation_eventable_id)

    # Contact.where.not(id: validation_events_ids) + Contact.where(id: failed_contacts)
    Contact.where.not(id: validation_events_ids) | failed_contacts
  end
end

def failed_contacts
  failed_contacts = []
  failed_validations_ids = ValidationEvent.failed.pluck(:validation_eventable_id)
  contacts = Contact.where(id: failed_validations_ids)
  contacts.each do |contact|

    if contact.validation_events.mx.order(created_at: :asc).present?
      failed_contacts << contact unless contact.validation_events.mx.order(created_at: :asc).last.success
    end

    if contact.validation_events.regex.order(created_at: :asc).present?
      failed_contacts << contact unless contact.validation_events.regex.order(created_at: :asc).last.success
    end

    if contact.validation_events.smtp.order(created_at: :asc).present?
      failed_contacts << contact unless contact.validation_events.mx.order(created_at: :asc).last.success
    end
  end

  failed_contacts.uniq
end

def contacts_by_domain(domain_name)
  domain = ::Domain.find_by(name: domain_name)
  return unless domain

  domain.contacts
end

def opts_hash
  {
    domain_name: ['-d [DOMAIN_NAME]', '--domain_name [DOMAIN_NAME]', String],
    check_level: ['-c [CHECK_LEVEL]', '--check_level [CHECK_LEVEL]', String],
    spam_protect: ['-s [SPAM_PROTECT]', '--spam_protect [SPAM_PROTECT]', FalseClass],
  }
end
