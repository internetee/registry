class ValidateDnssecJob < ApplicationJob
  discard_on StandardError

  def perform(domain_name: nil)
    unless domain_name.nil?
      domain = Domain.find_by(name: domain_name)

      return logger.info "No domain found" if domain.nil?

      return logger.info "No related nameservers for this domain" if domain.nameservers.empty?

      iterate_nameservers(domain)
    else
      domain_list = Domain.all.reject { |d| d.nameservers.empty? }

      domain_list.each do |d|
        iterate_nameservers(d)
      end
    end
  rescue StandardError => e
    logger.error e.message
    raise e
  end

  private

  def iterate_nameservers(domain)
    domain.nameservers.each do |n|
      text = "Hostname nameserver #{n.hostname}"
      flag = validate(name: n.hostname)
      if flag.nil?
        logger.info "#{text} - #{log_templates['false']}"
      else
        logger.info "#{text} - #{log_templates['true']}"
      end

      logger.info "----------------------------"
    end
  end

  def validate(name:, resolver: prepare_validator, type: 'DNSKEY', klass: 'IN')
    # make_query(name: hostname)
    resolver.query(name, type, klass)
  rescue Exception => e
    logger.error e.message
    nil
  end

  def prepare_validator
    dns_servers = ENV['dnssec_resolver_ips'].to_s.split(',').map(&:strip)
    inner_resolver = Dnsruby::Resolver.new
    inner_resolver.do_validation = true
    inner_resolver.dnssec = true
    inner_resolver.nameserver = dns_servers
    resolver = Dnsruby::Recursor.new(inner_resolver)
    resolver.dnssec = true

    resolver
  end

  def make_query(name:, resolver: prepare_validator, type: 'DNSKEY', klass: 'IN')
    logger.info "DNS query to #{name}; type: #{type}"
    resolver.query(name, type, klass)
  rescue Dnsruby::NXDomain
    false
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


  #
  #
  # def iterate_domain_data(domain:)
  #   zone_datas = get_data_from_zone(domain: domain)
  #   flag = domain.dnskeys.all? { |key| validate(zone_datas: zone_datas, domain_dnskey: key) }
  #
  #   flag
  # end
  #
  # def get_data_from_zone(domain:)
  #   resolver = prepare_resolver
  #   ds_records_answers = resolver.query(domain.name, 'DNSKEY').answer
  #
  #   result_container = []
  #
  #   ds_records_answers.each do |ds|
  #     next unless ds.type == Dnsruby::Types.DNSKEY
  #
  #     result_container << {
  #       flags: ds.flags.to_s,
  #       algorithm: ds.algorithm.code.to_s,
  #       protocol: ds.protocol.to_s,
  #       public_key: ds.public_key.export.gsub!(/\s+/, ''),
  #     }
  #   end
  #
  #   result_container
  # rescue Dnsruby::NXDomain
  #   domain.add_epp_error('2308', nil, nil, I18n.t(:dns_policy_violation))
  # end
  #
  # def validate(zone_datas:, domain_dnskey:)
  #   flag = zone_datas.any? do |zone_data|
  #     zone_data[:flags] == domain_dnskey.flags.to_s &&
  #       zone_data[:algorithm] == domain_dnskey.alg.to_s &&
  #       zone_data[:protocol] == domain_dnskey.protocol.to_s &&
  #       zone_data[:public_key].include?(domain_dnskey[:public_key].to_s)
  #   end
  #
  #   text = "#{domain_dnskey.flags} - #{domain_dnskey.alg} -
  #           #{domain_dnskey.protocol} - #{domain_dnskey.public_key} "
  #   logger.info text + log_templates[flag.to_s]
  #
  #   flag
  # end
  #
  # def prepare_resolver
  #   dns_servers = ENV['dnssec_resolver_ips'].to_s.split(',').map(&:strip)
  #   dns = Dnsruby::Resolver.new({ nameserver: dns_servers })
  #   dns.do_validation = true
  #   dns.do_caching = true
  #   dns.dnssec = true
  #
  #   dns
  # end


end
