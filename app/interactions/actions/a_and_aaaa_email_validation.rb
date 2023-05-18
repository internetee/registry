module Actions
  module AAndAaaaEmailValidation
    extend self

    def call(email:, value:)
      check_for_records_value(email: email, value: value)
    end

    private

    def check_for_records_value(email:, value:)
      email_domain = Mail::Address.new(email).domain
      dns_servers = ENV['dnssec_resolver_ips'].to_s.split(',').map(&:strip)

      resolve_a_and_aaaa_records(dns_servers: dns_servers, email_domain: email_domain, value: value)
    end

    def resolve_a_and_aaaa_records(dns_servers:, email_domain:, value:)
      Resolv::DNS.open(nameserver: dns_servers, ndots: 1, search: []) do |dns|
        dns.timeouts = (ENV['a_and_aaaa_validation_timeout'] || 1).to_i

        case value
        when 'A'
          resolve_a_records(dns: dns, hostname: email_domain)
        when 'AAAA'
          resolve_aaaa_records(dns: dns, hostname: email_domain)
        else
          []
        end
      end
    end

    def resolve_a_records(dns:, hostname:)
      resources = dns.getresources(hostname, Resolv::DNS::Resource::IN::A)
      resources.map(&:address)
    end

    def resolve_aaaa_records(dns:, hostname:)
      resources = dns.getresources(hostname, Resolv::DNS::Resource::IN::AAAA)
      resources.map(&:address)
    end
  end
end
