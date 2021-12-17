require 'optparse'
require 'rake_option_parser_boilerplate'
require 'syslog/logger'
require 'active_record'

namespace :verify_email do
  # bundle exec rake verify_email:check_all -- --domain_name=shop.test --check_level=mx --spam_protect=true
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

    batch_contacts = prepare_contacts(options)
    logger.info 'No contacts to check email selected' and next if batch_contacts.blank?

    batch_contacts.find_in_batches(batch_size: 10_000) do |contacts|
      contacts.each do |contact|
        VerifyEmailsJob.set(wait_until: spam_protect_timeout(options)).perform_later(
          contact: contact,
          check_level: check_level(options)
        ) if filter_check_level(contact)
      end
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

def prepare_contacts(options)
  if options[:domain_name].present?
    contacts_by_domain(options[:domain_name])
  else
    time = Time.zone.now - ValidationEvent::VALIDATION_PERIOD
    validation_events_ids = ValidationEvent.where('created_at > ?', time).distinct.pluck(:validation_eventable_id)

    contacts_ids = Contact.where.not(id: validation_events_ids).pluck(:id)
    Contact.where(id: contacts_ids + failed_contacts)
  end
end

def filter_check_level(contact)
  return true unless contact.validation_events.exists?

  data = contact.validation_events.order(created_at: :asc).last

  return true if data.successful? && data.created_at < (Time.zone.now - ValidationEvent::VALIDATION_PERIOD)

  if data.failed?
    return false if data.event_data['check_level'] == 'regex'

    # return false if data.event_data['check_level'] == 'smtp'
    #
    # return false if check_mx_contact_validation(contact)

    return true
  end

  false
end

def failed_contacts
  failed_contacts = []
  failed_validations_ids = ValidationEvent.failed.distinct.pluck(:validation_eventable_id)
  contacts = Contact.where(id: failed_validations_ids).includes(:validation_events)
  contacts.find_each(batch_size: 10_000) do |contact|
    failed_contacts << contact.id if filter_check_level(contact)
  end

  failed_contacts.uniq
end

# def check_mx_contact_validation(contact)
#   data = contact.validation_events.mx.order(created_at: :asc).last(ValidationEvent::MX_CHECK)
#
#   return false if data.size < ValidationEvent::MX_CHECK
#
#   data.all? { |d| d.failed? }
# end

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
