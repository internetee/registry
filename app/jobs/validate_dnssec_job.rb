class ValidateDnssecJob < ApplicationJob
  discard_on StandardError

  def perform(domain_name: nil)
    unless domain_name.nil?
      domain = Domain.find_by(name: domain_name)

      return logger.info "No domain found" if domain.nil?

      return logger.info "No related dnskeys for this domain" if domain.dnskeys.empty?

      flag = iterate_domain_data(domain: domain)
      logger.info "#{domain_name} " + log_templates[flag.to_s]
    else
      Dnskey.all.each do |key|
        domain = Domain.find(key.domain_id)

        flag = iterate_domain_data(domain: domain)
        logger.info "#{domain.name} " + log_templates[flag.to_s]
      end
    end
  rescue StandardError => e
    logger.error e.message
    raise e
  end

  private

  def iterate_domain_data(domain:)
    zone_datas = get_data_from_zone(domain: domain)
    flag = domain.dnskeys.all? { |key| validate(zone_datas: zone_datas, domain_dnskey: key) }

    flag
  end

  def get_data_from_zone(domain:)
    resolver = prepare_resolver
    ds_records_answers = resolver.query(domain.name, 'DNSKEY').answer

    result_container = []

    ds_records_answers.each do |ds|
      next unless ds.type == Dnsruby::Types.DNSKEY

      result_container << {
        flags: ds.flags.to_s,
        algorithm: ds.algorithm.code.to_s,
        protocol: ds.protocol.to_s,
        public_key: ds.public_key.export.gsub!(/\s+/, ''),
      }
    end

    result_container
  rescue Dnsruby::NXDomain
    domain.add_epp_error('2308', nil, nil, I18n.t(:dns_policy_violation))
  end

  def validate(zone_datas:, domain_dnskey:)
    flag = zone_datas.any? do |zone_data|
      zone_data[:flags] == domain_dnskey.flags.to_s &&
        zone_data[:algorithm] == domain_dnskey.alg.to_s &&
        zone_data[:protocol] == domain_dnskey.protocol.to_s &&
        zone_data[:public_key].include?(domain_dnskey[:public_key].to_s)
    end

    text = "#{domain_dnskey.flags} - #{domain_dnskey.alg} -
            #{domain_dnskey.protocol} - #{domain_dnskey.public_key} "
    logger.info text + log_templates[flag.to_s]

    flag
  end

  def prepare_resolver
    dns_servers = ENV['dnssec_resolver_ips'].to_s.split(',').map(&:strip)
    dns = Dnsruby::Resolver.new({ nameserver: dns_servers })
    dns.do_validation = true
    dns.do_caching = true
    dns.dnssec = true

    dns
  end

  def log_templates
    {
      "true" => "validated successfully",
      "false" => "validated fail"
    }
  end

  def logger
    @logger ||= Rails.logger
  end
end
