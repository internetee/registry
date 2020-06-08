# frozen_string_literal: true

class CsyncJob < Que::Job
  def run(generate: false)
    @store = {}
    @results = {}
    @logger = Logger.new(STDOUT)
    generate ? generate_scanner_input : process_scanner_results

    @logger.info 'CsyncJob: Finished.'
  end

  def qualified_for_monitoring?(domain, data)
    result_types = data[:ns].map { |ns| ns[:type] }.uniq
    ns_ok = result_types == ['insecure']
    key_ok = data[:ns].map { |ns| ns[:cdnskey] }.uniq.size == 1

    return true if ns_ok && key_ok

    reason = !ns_ok ? 'no key found / NS unavailable' : 'different CDNSKEY entries'
    @logger.info "CsyncJob: Reseting Csync state for '#{domain}'. Reason: #{reason}"
    CsyncRecord.clear(domain)

    false
  end

  def process_scanner_results
    scanner_results

    @results.keys.each do |domain|
      next unless qualified_for_monitoring?(domain, @results[domain])

      CsyncRecord.by_domain_name(domain)&.record_new_scan(@results[domain][:ns].first)
    end
  end

  def scanner_results
    scanner_line_results.each do |fetch|
      domain_name = fetch[:domain]
      @results[domain_name] = { ns: [] } unless @results[domain_name]
      @results[domain_name][:ns] << fetch.except(:domain)
    end
  end

  def scanner_line_results
    records = []
    File.open(ENV['cdns_scanner_output_file'], 'r').each_line do |line|
      # Input type, NS host, NS IP, Domain name, Key type, Protocol, Algorithm, Public key
      data = line.strip.split(' ')
      type, ns, ns_ip, domain, key_bit, proto, alg, pub = data
      cdnskey = key_bit && proto && alg && pub ? "#{key_bit} #{proto} #{alg} #{pub}" : nil
      record = { domain: domain, type: type, ns: ns, ns_ip: ns_ip, flags: key_bit, proto: proto,
                 alg: alg, pub: pub, cdnskey: cdnskey }
      records << record
    end
    records
  end

  # From this point we're working on generating input for cdnskey-scanner
  def gather_pollable_domains
    Nameserver.select(:hostname, :domain_id).all.each do |ns|
      @store[ns.hostname] = [] unless @store.key? ns.hostname

      Domain.where(id: ns.domain_id).all.each do |domain|
        @store[ns.hostname].push domain.name
      end
    end
  end

  def generate_scanner_input
    @logger.info 'CsyncJob Generate: Gathering current domain(s) data'
    gather_pollable_domains

    @logger.info 'CsyncJob Generate: Writing input for cdnskey-scanner to ' \
    "#{ENV['cdns_scanner_input_file']}"
    out_file = File.new(ENV['cdns_scanner_input_file'], 'w+')

    out_file.puts '[insecure]'
    create_input_lines(out_file)

    out_file.close
    @logger.info 'CsyncJob Generate: Finished writing output.'
  end

  def create_input_lines(out_file)
    @store.keys.each do |nameserver|
      domains = @store[nameserver].join(' ')
      next unless domains.length.positive?

      out_file.puts "#{nameserver} #{domains}"
    end
  end
end
