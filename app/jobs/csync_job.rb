# frozen_string_literal: true

class CsyncJob < Que::Job
  def run(generate: false, ipv6: false)
    @ipv6 = ipv6
    @logger = Logger.new(STDOUT)
    generate ? generate_scanner_input : process_scanner_results
  end

  def process_scanner_results
    scanner_results.keys.each do |domain|
      result = scanner_results[domain]
      result_types = result[:ns].map { |ns| ns[:type] }.uniq
      success = result_types.size == 1 && fetch_result_types.included_in?(%w[secure insecure])

      # WIP
    end
  end

  def scanner_results
    results = scanner_line_results
    combined_results = {}
    results.each do |fetch|
      next if !@ipv6 && fetch[:ns_ip].include?(':')

      combined_results[fetch[:domain]] = { ns: [] } unless combined_results.key? fetch[:domain]
      combined_results[fetch[:domain]][:ns] << fetch.except(:domain)
    end

    combined_results
  end

  def scanner_line_results
    records = []
    File.open(ENV['cdns_scanner_output_file'], 'r').each_line do |line|
      # Input type, NS host, NS IP, Domain name, Key type, Protocol, Algorithm, Public key
      data = line.strip.split(' ')
      type, ns, ns_ip, domain, key_bit, proto, alg, pub = data
      cdnskey = key_bit && proto && alg && pub ? "#{key_bit} #{proto} #{alg} #{pub}" : nil
      record = { domain: domain, type: type, ns: ns, ns_ip: ns_ip, key_bit: key_bit, proto: proto,
                 alg: alg, pub: pub, cdnskey: cdnskey }
      records << record
    end
    records
  end

  # From this point we're working on generating input for cdnskey-scanner
  def gather_pollable_domains
    @logger.info 'CsyncJob Generate: Gathering current domain(s) data'
    @store = { secure: {}, insecure: {} }
    Nameserver.select(:hostname, :domain_id).all.each do |ns|
      @store[:secure][ns.hostname] = [] unless @store[:secure].key? ns.hostname
      @store[:insecure][ns.hostname] = [] unless @store[:insecure].key? ns.hostname

      Domain.where(id: ns.domain_id).all.each do |domain|
        state = domain.dnskeys.any? ? :secure : :insecure
        @store[state][ns.hostname].push domain.name
      end
    end
  end

  def generate_scanner_input
    gather_pollable_domains

    @logger.info 'CsyncJob Generate: Writing input for cdnskey-scanner to ' \
    "#{ENV['cdns_scanner_input_file']}"
    out_file = File.new(ENV['cdns_scanner_input_file'], 'w+')

    out_file.puts '[secure]'
    create_input_lines(out_file, secure: true)
    out_file.puts '[insecure]'
    create_input_lines(out_file, secure: false)

    out_file.close
    @logger.info 'CsyncJob Generate: Finished writing output.'
  end

  def create_input_lines(out_file, secure: false)
    state = secure ? :secure : :insecure
    @store[state].keys.each do |nameserver|
      domains = @store[state][nameserver].join(' ')
      next unless domains.length.positive?

      out_file.puts "#{nameserver} #{domains}"
    end
  end
end
