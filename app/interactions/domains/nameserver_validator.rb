module Domains
  module NameserverValidator
    include Dnsruby

    extend self

    def run(hostname:)
      validate(hostname)
    end

    private

    def validate(hostname)
      resolver = setup_resolver
      result = resolver.query(hostname, Dnsruby::Types.SOA)

      return { result: false, reason: 'authority' } if result.authority.empty?

      decision = result.authority.all? do |a|
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

    def setup_resolver
      timeout = ENV['nameserver_validation_timeout'] || '1'
      dns_servers = ENV['dnssec_resolver_ips'].to_s.split(',').map(&:strip)
      Resolver.new({nameserver: dns_servers, timeout: timeout.to_i})
    end

    def logger
      @logger ||= Rails.logger
    end
  end
end
