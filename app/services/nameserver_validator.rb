module NameserverValidator
  include Dnsruby

  extend self

  VALIDATION_NAMESERVER_PERIOD = 1.year.freeze
  VALIDATION_DOMAIN_PERIOD = 8.hours.freeze
  VALID_NAMESERVER_COUNT_THRESHOLD = 3

  def run(domain_name:, hostname:)
    validate(domain_name: domain_name, hostname: hostname)
  end

  private

  def validate(domain_name: , hostname:)
    resolver = setup_resolver(hostname)
    result = resolver.query(domain_name, 'SOA', 'IN')

    return { result: false, reason: 'answer' } if result.answer.empty?

    decision = result.answer.all? do |a|
      a.serial.present?
    end

    return { result: false, reason: 'serial' } unless decision

    logger.info "Serial number - #{result.answer[0].serial.to_s} of #{hostname} - domain name: #{domain_name}"

    { result: true, reason: '' }
  rescue StandardError => e
    logger.error e.message
    logger.error "failed #{hostname} validation of #{domain_name} domain name"
    return { result: false, reason: 'exception', error_info: e }
  end

  def setup_resolver(hostname)
    resolver = Dnsruby::Resolver.new
    resolver.retry_times = 3
    resolver.recurse = 0  # Send out non-recursive queries
    # disable caching otherwise SOA is cached from first nameserver queried
    resolver.do_caching = false
    resolver.nameserver = hostname

    resolver
  end

  def logger
    @logger ||= Rails.logger
  end
end
