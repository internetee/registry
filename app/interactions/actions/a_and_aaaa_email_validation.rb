module Actions
  module AAndAaaaEmailValidation
    extend self

    def call(email:, value:)
      check_for_records_value(email: email, value: value)
    end

    private

    def check_for_records_value(email:, value:)
      email = Mail::Address.new(email).domain
      result = nil
      dns_servers = ENV['dnssec_resolver_ips'].to_s.split(',').map(&:strip)

      Resolv::DNS.open({ nameserver: dns_servers }) do |dns|
        dns.timeouts = ENV['a_and_aaaa_validation_timeout'].to_i || 1
        ress = nil

        case value
        when 'A'
          ress = dns.getresources email, Resolv::DNS::Resource::IN::A
        when 'AAAA'
          ress = dns.getresources email, Resolv::DNS::Resource::IN::AAAA
        end

        result = ress.map { |r| r.address }
      end

      result
    end
  end
end
