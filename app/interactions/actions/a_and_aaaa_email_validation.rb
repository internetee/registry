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
      Resolv::DNS.open({ nameserver: dns_servers }) do |dns|
        dns.timeouts = ENV['a_and_aaaa_validation_timeout'].to_i || 1
        ress = nil

        case value
        when 'A'
          ress = dns.getresources email_domain, Resolv::DNS::Resource::IN::A
        when 'AAAA'
          ress = dns.getresources email_domain, Resolv::DNS::Resource::IN::AAAA
        end

        ress.map(&:address)
      end
    end
  end
end
