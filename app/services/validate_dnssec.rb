module ValidateDnssec
  include Dnsruby

  extend self

  def prepare_resolver
    dns_servers = ENV['dnssec_resolver_ips'].to_s.split(',').map(&:strip)
    dns = Dnsruby::Resolver.new({ nameserver: dns_servers })
    dns.do_validation = false
    dns.do_caching = false
    dns.dnssec = true

    dns
  end

  def validate_dnssec(params:, domain:)
    return if params[:action] == 'rem'

    dns = prepare_resolver
    subzone_records = get_dnskey_records_from_subzone(resolver: dns, hostname: params[:domain], domain: domain)
    form_extension_records = extensional_dnskeys_data(params)

    return true if form_extension_records.empty?

    validate_data(subzone_records: subzone_records, form_extension_records: form_extension_records, domain: domain)
  end

  def make_magic(subzone_records:, form_data:)
    subzone_records.any? do |subzone_data|
      subzone_data[:basic] == form_data[:basic] &&
        subzone_data[:public_key].include?(form_data[:public_key])
    end
  end

  def validate_data(subzone_records:, form_extension_records:, domain:)
    flag = false
    form_extension_records.each do |form_data|
      flag = make_magic(subzone_records: subzone_records, form_data: form_data)

      break if flag
    end

    return validation_dns_key_error(domain) unless flag

    flag
  end

  def get_dnskey_records_from_subzone(resolver:, hostname:, domain:)
    ds_records_answers = resolver.query(hostname, 'DNSKEY').answer

    result_container = []

    ds_records_answers.each do |ds|
      next unless ds.type == Dnsruby::Types.DNSKEY

      result_container << {
        basic: {
          flags: ds.flags.to_s,
          algorithm: ds.algorithm.code.to_s,
          protocol: ds.protocol.to_s,
        },
        public_key: ds.public_key.export.gsub!(/\s+/, ''),
      }
    end

    result_container
  rescue Dnsruby::NXDomain
    domain.add_epp_error('2308', nil, nil, I18n.t(:dns_policy_violation))
  end

  def validation_dns_key_error(domain)
    domain.add_epp_error('2308', nil, nil, I18n.t(:dns_policy_violation))
  end

  def extensional_dnskeys_data(params)
    dnskeys_data = params[:dns_keys]

    return [] if dnskeys_data.nil?

    result_container = []

    dnskeys_data.each do |ds|
      next if ds[:action] == 'rem'

      result_container << {
        basic: {
          flags: ds[:flags].to_s,
          algorithm: ds[:alg].to_s,
          protocol: ds[:protocol].to_s,
        },
        public_key: ds[:public_key],
      }
    end

    result_container
  end
end
