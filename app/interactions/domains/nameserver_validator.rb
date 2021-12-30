module Domains
  module NameserverValidator
    include Dnsruby

    extend self

    def run(hostname:, nameserver_address:)
      validate(hostname: hostname, nameserver_address: nameserver_address)
    end

    private

    def validate(hostname: , nameserver_address:)
      resolver = Resolver.new
      resolver.nameserver = nameserver_address
      result = resolver.query(hostname, Dnsruby::Types.SOA)

      return { result: false, reason: 'answer' } if result.answer.empty?

      decision = result.answer.all? do |a|
        a.serial.present?
      end

      return { result: false, reason: 'serial' } unless decision

      { result: true, reason: '' }
    rescue Dnsruby::NXDomain => e
      logger.info "#{e} - seems hostname don't found"
      return { result: false, reason: 'not found' }
    rescue StandardError => e
      logger.info e
      return { result: false, reason: 'exception', error_info: e }
    end

    def setup_resolver(nameserver_address)
      # resolver.do_validation=true
      # resolver.query_timeout=1
      # resolver.single_resolvers[0].server='ns.tld.ee'
      timeout = ENV['nameserver_validation_timeout'] || '1'
      # dns_servers = ENV['dnssec_resolver_ips'].to_s.split(',').map(&:strip)
      # Resolver.new({nameserver: dns_servers, timeout: timeout.to_i})
      resolver = Resolver.new
      resolver.nameserver = nameserver_address

    end

    def logger
      @logger ||= Rails.logger
    end
  end
end
