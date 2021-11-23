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
      check_level: 'regex',
      spam_protect: false,
    }
    banner = 'Usage: rake verify_email:check_all -- [options]'
    options = RakeOptionParserBoilerplate.process_args(options: options,
                                                       banner: banner,
                                                       hash: opts_hash)

    batch_contacts = prepare_contacts(options)
    logger.info 'No contacts to check email selected' and next if batch_contacts.blank?

    batch_contacts.find_in_batches(batch_size: 10000) do |contacts|
      contacts.each do |contact|
        VerifyEmailsJob.set(wait_until: spam_protect_timeout(options)).perform_later(
          contact: contact,
          check_level: check_level(options)
        )
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

# Here I set the time after which the validation is considered obsolete
# I take all contact records that have successfully passed the verification and fall within the deadline
# I am looking for contacts that have not been verified or their verification is out of date

def prepare_contacts(options)
  if options[:domain_name].present?
    contacts_by_domain(options[:domain_name])
  else
    time = Time.zone.now - ValidationEvent::VALIDATION_PERIOD
    validation_events_ids = ValidationEvent.where('created_at > ?', time).distinct.pluck(:validation_eventable_id)

    contacts_ids = Contact.where.not(id: validation_events_ids).pluck(:id)
    Contact.where(id: contacts_ids + failed_contacts(options))
  end
end

def failed_contacts(options)
  failed_contacts = []
  failed_validations_ids = ValidationEvent.failed.distinct.pluck(:validation_eventable_id)
  contacts = Contact.where(id: failed_validations_ids).includes(:validation_events)
  contacts.find_each(batch_size: 10000) do |contact|

    data = contact.validation_events.order(created_at: :asc).last

    if data.failed?
      next if data.event_data['check_level'] == 'regex'

      next if data.event_data['check_level'] == 'smtp'

      next if check_mx_contact_validation(contact)

      failed_contacts << contact.id
    end

    # case options[:check_level]
    # when 'mx'
    #   failed_contacts << unsuccess_mx(contact)
    # when 'regex'
    #   failed_contacts << unsuccess_regex(contact)
    # when 'smtp'
    #   failed_contacts << unsuccess_smtp(contact)
    # else
    #   failed_contacts << unsuccess_mx(contact)
    #   failed_contacts << unsuccess_regex(contact)
    #   failed_contacts << unsuccess_smtp(contact)
    # end
  end

  failed_contacts.uniq
end

def check_mx_contact_validation(contact)
  data = contact.validation_events.order(created_at: :asc).last(3)
  flag = data.all? { |d| d.failed? }

  flag
end

# def unsuccess_mx(contact)
#   if contact.validation_events.mx.order(created_at: :asc).present?
#     contact.id unless contact.validation_events.mx.order(created_at: :asc).last.success
#   end
# end
#
# def unsuccess_regex(contact)
#   if contact.validation_events.regex.order(created_at: :asc).present?
#     contact.id unless contact.validation_events.regex.order(created_at: :asc).last.success
#   end
# end
#
# def unsuccess_smtp(contact)
#   if contact.validation_events.smtp.order(created_at: :asc).present?
#     contact.id unless contact.validation_events.smtp.order(created_at: :asc).last.success
#   end
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
