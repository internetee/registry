require 'optparse'
require 'rake_option_parser_boilerplate'
require 'syslog/logger'
require 'active_record'

SPAM_PROTECT_TIMEOUT = 30.seconds

task verify_domain: :environment do
  options = {
    domain_name: nil,
    check_level: 'mx',
    spam_protect: false,
  }
  banner = 'Usage: rake verify_domain -- [options]'
  options = RakeOptionParserBoilerplate.process_args(options: options,
                                                     banner: banner,
                                                     hash: opts_hash)

  
  domain = Domain.find_by(name: options[:domain_name])
  check_level = options[:check_level]

  domain.domain_contacts.each do |dc|
    dc.contact.verify_email(check_level: check_level, single_email: true)

    Rails.logger.info "Validated contact with code #{dc.contact.code} and email #{dc.contact.email} of #{domain.name} domain"
    Rails.logger.info "Result - #{dc.contact.validation_events.last.success}"
  end
end
