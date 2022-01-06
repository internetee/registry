module SoaNameserverQuery
  include Dnsruby

  extend self

  def validate(domain_name:, hostname:)

      resolver = create_resolver(hostname)

      answers = resolver.query(domain_name, 'SOA', 'IN')
      answers.answer.each do |a|

        if a.serial.nil?
          logger.info "No serial number of nameserver found"

          return false
        end

        serial_number = a.serial.to_s

        p "-------------- >>"
        p "serial number #{serial_number} of #{hostname} - domain name: #{domain_name}"
        p "<< --------------"
        true
      end

  rescue StandardError => e
    logger.error e.message
    logger.error "failed #{hostname} validation of #{domain_name} domain name"

    false
  end

  private

  def create_resolver(nameserver)
    resolver = Dnsruby::Resolver.new
    resolver.retry_times = 3
    resolver.recurse = 0  # Send out non-recursive queries
    # disable caching otherwise SOA is cached from first nameserver queried
    resolver.do_caching = false
    resolver.nameserver = nameserver
    resolver
  end

  def logger
    @logger ||= Rails.logger
  end
end
