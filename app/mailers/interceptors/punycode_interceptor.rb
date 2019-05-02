class PunycodeInterceptor
  class << self
    def delivering_email(message)
      message.from = encode_addresses_as_punycode(message.from)
      message.to = encode_addresses_as_punycode(message.to)
      message.cc = encode_addresses_as_punycode(message.cc) if message.cc
      message.bcc = encode_addresses_as_punycode(message.bcc) if message.bcc
    end

    private

    def encode_addresses_as_punycode(addresses)
      addresses.map do |address|
        local_part, domain_part = address.split('@')
        domain_part = encode_domain_part_as_punycode(domain_part)
        [local_part, '@', domain_part].join
      end
    end

    def encode_domain_part_as_punycode(domain_part)
      SimpleIDN.to_ascii(domain_part)
    end
  end
end