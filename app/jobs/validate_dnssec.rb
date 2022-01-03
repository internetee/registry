class ValidateDnssecJob < ApplicationJob
  discard_on StandardError

  def perform(domain_name:)

  rescue StandardError => e
    logger.error e.message
    raise e
  end

  private

  def prepare_resolver
    dns_servers = ENV['dnssec_resolver_ips'].to_s.split(',').map(&:strip)
    dns = Dnsruby::Resolver.new({ nameserver: dns_servers })
    dns.do_validation = false
    dns.do_caching = false
    dns.dnssec = true

    dns
  end



end
